<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.roomlagbe.config.DBConnection, com.roomlagbe.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);

    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        currentPage = Integer.parseInt(pageParam);
    }
    
    // Strict Guest Limitation: Stop them from going past page 1
    if (!isLoggedIn && currentPage > 1) {
        response.sendRedirect("index.jsp?showLoginModal=true");
        return;
    }

    int recordsPerPage = 5; 
    int startRecord = (currentPage - 1) * recordsPerPage;

    String district = request.getParameter("district");
    String postOffice = request.getParameter("post_office");
    String area = request.getParameter("area");
    String genderPref = request.getParameter("preferred_gender");
    String minRent = request.getParameter("min_rent");
    String maxRent = request.getParameter("max_rent");
    String searchCode = request.getParameter("search_code");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Home</title>
    <%@ include file="_styles.jsp" %>
    <style>
        /* Embedded layout overrides for the dynamic feed presentation splits */
        .home-main-layout { display: flex; gap: 20px; margin-top: 20px; }
        .filter-sidebar-section { flex: 1; min-width: 260px; background: #f9f9f9; padding: 15px; border-radius: 4px; height: fit-content; }
        .feed-content-section { flex: 3; }
        .ad-banner-horizontal { width: 100%; height: 90px; background: #eee; display: flex; align-items: center; justify-content: center; margin: 10px 0; border: 1px dashed #ccc; font-size: 12px; color: #666; }
        .ad-box-vertical { width: 100%; height: 250px; background: #eee; display: flex; align-items: center; justify-content: center; margin-top: 20px; border: 1px dashed #ccc; font-size: 12px; color: #666; }
        .room-display-card { display: flex; border: 1px solid #ddd; border-radius: 6px; margin-bottom: 20px; overflow: hidden; background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .card-photo-slider-pane { flex: 1; max-width: 240px; background: #f0f0f0; min-height: 160px; overflow-x: auto; display: flex; align-items: center; }
        .card-details-text-pane { flex: 2; padding: 15px; display: flex; flex-direction: column; justify-content: space-between; }
        .slider-thumbnail-img { width: 100%; height: 160px; object-fit: cover; flex-shrink: 0; }
        .auth-modal-overlay-backdrop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 9999; }
        .auth-modal-content-wrapper { background: #fff; padding: 30px; border-radius: 8px; max-width: 400px; text-align: center; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <!-- Header Ad Banner Component[cite: 1] -->
    <div class="ad-banner-horizontal">
        <span>[Header Advertisement Banner Slot]</span>
    </div>

    <div class="container home-main-layout">
        
        <!-- 1. Dynamic Dropdown Cascading Filtering Pane -->
        <aside class="filter-sidebar-section">
            <h3 class="section-title">Filter Matrix</h3>
            <form action="index.jsp" method="GET" class="minimalist-filter-form">
            
            <!-- START: TEXT FIELD FOR TRACKING CODE SEARCH -->
                <div class="form-group-item" style="margin-bottom: 15px;">
                    <label class="field-label" style="font-weight: bold; color: #2563eb;">Search by Room Code</label>
                    <input type="text" name="search_code" class="form-control-input" placeholder="e.g., RL-00103" value="<%= request.getParameter("search_code") != null ? request.getParameter("search_code") : "" %>" style="border: 1px solid #2563eb;">
                </div>
                <!-- END: TEXT FIELD FOR TRACKING CODE SEARCH -->
                
                <div class="form-group-item">
                    <label class="field-label">District</label>
                    <select name="district" id="districtSelect" class="form-control-input" onchange="loadPostOffices()">
                        <option value="">Select District</option>
                        <%
                            try (Connection conn = DBConnection.getConnection();
                                 Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery("SELECT DISTINCT district FROM LOCATIONS ORDER BY district")) {
                                while (rs.next()) {
                                    String d = rs.getString("district");
                                    String sel = d.equals(district) ? "selected" : "";
                                    out.println("<option value='" + d + "' " + sel + ">" + d + "</option>");
                                }
                            } catch (Exception e) { e.printStackTrace(); }
                        %>
                    </select>
                </div>

                <div class="form-group-item">
                    <label class="field-label">Post Office</label>
                    <select name="post_office" id="postOfficeSelect" class="form-control-input" onchange="loadAreas()">
                        <option value="">Select Post Office</option>
                        <% if (postOffice != null && !postOffice.isEmpty()) { %>
                            <option value="<%= postOffice %>" selected><%= postOffice %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group-item">
                    <label class="field-label">Area</label>
                    <select name="area" id="areaSelect" class="form-control-input">
                        <option value="">Select Area</option>
                        <% if (area != null && !area.isEmpty()) { %>
                            <option value="<%= area %>" selected><%= area %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group-item">
                    <label class="field-label">Preferred Gender</label>
                    <select name="preferred_gender" class="form-control-input">
                        <option value="">Any Gender</option>
                        <option value="Male" <%="Male".equals(genderPref)?"selected":""%>>Male</option>
                        <option value="Female" <%="Female".equals(genderPref)?"selected":""%>>Female</option>
                    </select>
                </div>

                <div class="form-group-item">
                    <label class="field-label">Rent Limits (BDT)</label>
                    <div style="display:flex; gap:10px;">
                        <input type="number" name="min_rent" class="form-control-input" placeholder="Min" value="<%=minRent!=null?minRent:""%>">
                        <input type="number" name="max_rent" class="form-control-input" placeholder="Max" value="<%=maxRent!=null?maxRent:""%>">
                    </div>
                </div>

                <button type="submit" class="btn-action-trigger primary-theme-btn" style="width:100%; margin-top:15px;">Search Feed</button>
            </form>
            <!-- Inside the filter block of index.jsp -->
<div class="search-form-buttons" style="display: flex; gap: 10px; margin-top: 15px;">
    <!-- Your existing Search Button -->
   <!--   <button type="submit" class="btn btn-primary" style="flex: 1;">Search Rooms</button>-->
    
    <!-- NEW: Clear Filters Button -->
    <% 
        // Show the Clear button only if the user has actively filtered the results
        boolean hasFilters = request.getParameter("search_id") != null || 
                             request.getParameter("district") != null || 
                             request.getParameter("area") != null || 
                             request.getParameter("preferred_gender") != null;
                             
        if (hasFilters) { 
    %>
        <a href="index.jsp" class="btn btn-secondary" 
           style="flex: 1; background-color: #6c757d; color: white; text-align: center; text-decoration: none; padding: 8px 12px; border-radius: 4px; display: inline-block;">
           Clear Filters
        </a>
    <% } %>
</div>





            <!-- Sidebar Ad Placeholder[cite: 1] -->
            <div class="ad-box-vertical">
                <span>[Sidebar Ads Box Slot]</span>
            </div>
        </aside>

        <!-- 2. Dynamic Live Room Ads Content Feed -->
        <section class="feed-content-section">
            <h2 class="main-feed-heading">Available Room Accommodations</h2>
            <hr class="flat-divider" />

            <%
    StringBuilder sql = new StringBuilder(
        "SELECT l.*, (SELECT MIN(p.photo_path) FROM LISTING_PHOTOS p WHERE p.listing_id = l.listing_id) as primary_thumb " +
        "FROM LISTINGS l WHERE l.status = 'Ad running'"
    );

    // START: PARSE DYNAMIC LISTING SEARCH CODE
    int parsedCodeId = -1;
    if (searchCode != null && !searchCode.trim().isEmpty()) {
        String cleanCode = searchCode.trim().toUpperCase().replace("RL-", "");
        try {
            parsedCodeId = Integer.parseInt(cleanCode);
        } catch (NumberFormatException e) {
            parsedCodeId = -2; // Marker for an invalid code string that won't match any real ID
        }
    }
    // END: PARSE DYNAMIC LISTING SEARCH CODE

    // Append standard drop-down filter rules
    if (district != null && !district.isEmpty()) sql.append(" AND l.district = ?");
    if (postOffice != null && !postOffice.isEmpty()) sql.append(" AND l.post_office = ?");
    if (area != null && !area.isEmpty()) sql.append(" AND l.area = ?");
    if (genderPref != null && !genderPref.isEmpty()) sql.append(" AND l.preferred_gender = ?");
    if (minRent != null && !minRent.isEmpty()) sql.append(" AND l.rent >= ?");
    if (maxRent != null && !maxRent.isEmpty()) sql.append(" AND l.rent <= ?");
    
    // START: APPEND CODE IDENTIFIER CONDITION TO QUERY
    if (parsedCodeId != -1) {
        sql.append(" AND l.listing_id = ?");
    }
    // END: APPEND CODE IDENTIFIER CONDITION TO QUERY

    sql.append(" ORDER BY l.publish_date DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
    
    
    
    

    int activeAdCardCount = 0;
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
        
        int idx = 1;
        if (district != null && !district.isEmpty()) stmt.setString(idx++, district);
        if (postOffice != null && !postOffice.isEmpty()) stmt.setString(idx++, postOffice);
        if (area != null && !area.isEmpty()) stmt.setString(idx++, area);
        if (genderPref != null && !genderPref.isEmpty()) stmt.setString(idx++, genderPref);
        if (minRent != null && !minRent.isEmpty()) stmt.setDouble(idx++, Double.parseDouble(minRent));
        if (maxRent != null && !maxRent.isEmpty()) stmt.setDouble(idx++, Double.parseDouble(maxRent));
        
        // START: BIND CODE IDENTIFIER TO PREPARED STATEMENT
        if (parsedCodeId != -1) {
            stmt.setInt(idx++, parsedCodeId);
        }
        // END: BIND CODE IDENTIFIER TO PREPARED STATEMENT
        
        stmt.setInt(idx++, startRecord);
        stmt.setInt(idx++, recordsPerPage);

                    try (ResultSet rs = stmt.executeQuery()) {
                    	while (rs.next()) {
                            activeAdCardCount++;
                            int listingId = rs.getInt("listing_id");
                            String title = rs.getString("title");
                            double rent = rs.getDouble("rent");
                            String areaName = rs.getString("area");
                            String prefGender = rs.getString("preferred_gender");
                            String datePub = rs.getDate("publish_date").toString();
                            int reqRoommates = rs.getInt("required_roommates");
                            
                            String imageFile = rs.getString("primary_thumb");
                            if (imageFile == null) {
                                imageFile = "/images/room-placeholder.png";
                            }
                            
                            // START: GENERATE CODE LOOK (e.g., RL-00103)
                            // START: GENERATE LOCATION-BASED DYNAMIC CODE
String dbDistrict = rs.getString("district");
String dbArea = rs.getString("area");
String firstLetter = (dbDistrict != null && !dbDistrict.trim().isEmpty()) ? dbDistrict.trim().substring(0, 1).toUpperCase() : "R";
String secondLetter = (dbArea != null && !dbArea.trim().isEmpty()) ? dbArea.trim().substring(0, 1).toUpperCase() : "L";
String customListingCode = String.format("%s%s-%05d", firstLetter, secondLetter, listingId);
// END: GENERATE LOCATION-BASED DYNAMIC CODE
                            // END: GENERATE CODE LOOK
            %>
                            <!-- Unified Structural Room Card[cite: 1] -->
                            <div class="room-display-card">
                                <div class="card-photo-slider-pane">
                                    <img src="<%= request.getContextPath() + imageFile %>" alt="Room preview Image" class="slider-thumbnail-img">
                                </div>
                                <div class="card-details-text-pane">
                <div>
                    <!-- START: SHOW CODE LOOK -->
                    <span style="font-weight: bold; color: #2563eb; display: block; margin-bottom: 4px;"><%= customListingCode %></span>
                    <!-- END: SHOW CODE LOOK -->

                    <h3 style="margin:0 0 8px 0; color:#333;"><%= title %></h3>
                                        <p style="margin:4px 0; color:#666;"><strong>Location:</strong> <%= areaName %></p>
                                        <p style="margin:4px 0; color:#666;"><strong>Preference:</strong> Requires <%= prefGender %> Roommates</p>
                                        <p style="margin:4px 0; color:#999; font-size:12px;">Published on: <%= datePub %> | Seats Vacant: <%= reqRoommates %></p>
                                    </div>
                                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:15px;">
                                        <span style="font-size:18px; font-weight:bold; color:#28a745;"><%= rent %> BDT / month</span>
                                        <a href="viewlisting.jsp?id=<%= listingId %>" class="btn-action-trigger outline-secondary-btn">View Details</a>
                                    </div>
                                </div>
                            </div>
            <%
                            // Intermittent Mid-Feed Ad Banner Placement Injection
                            if (activeAdCardCount == 2) {
                                out.println("<div class='ad-banner-horizontal'><span>[Mid-Feed Intermediate Advertisement Slot]</span></div>");
                            }
                        }
                    }
                } catch (Exception e) { e.printStackTrace(); }

                if (activeAdCardCount == 0) {
                    out.println("<p class='empty-state-notice'>No verified active listings match your selection filters.</p>");
                }
            %>

            <!-- 3. Dynamic Footer Pagination Block Components[cite: 1] -->
            <div class="pagination-navigation-row" style="display:flex; justify-content:center; gap:15px; margin:30px 0;">
                <% if (currentPage > 1) { %>
                    <a href="index.jsp?page=<%= currentPage - 1 %>" class="btn-action-trigger text-link-btn">« Previous Page</a>
                <% } %>
                
                <% if (isLoggedIn) { %>
                    <a href="index.jsp?page=<%= currentPage + 1 %>" class="btn-action-trigger text-link-btn">Next Page »</a>
                <% } else { %>
                    <!-- Guests are hard-blocked and instantly routed into visibility alert blocks[cite: 1] -->
                    <a href="index.jsp?showLoginModal=true" class="btn-action-trigger text-link-btn">Next Page »</a>
                <% } %>
            </div>
        </section>
    </div>

    <!-- Restricted Guest View Warning Interface Container Modal[cite: 1] -->
    <% if ("true".equals(request.getParameter("showLoginModal"))) { %>
        <div class="auth-modal-overlay-backdrop">
            <div class="auth-modal-content-wrapper">
                <h3 style="margin-top:0; color:#dc3545;">Want to see more room options?</h3>
                <p style="color:#666; font-size:14px; line-height:1.5;">Guests are limited to viewing only 5 standard room advertisements. Create an account or sign in to browse all active listings across the platform.</p>
                <div style="display:flex; flex-direction:column; gap:10px; margin-top:20px;">
                    <a href="login.jsp" class="btn-action-trigger primary-theme-btn" style="text-decoration:none;">Sign In</a>
                    <a href="registration.jsp" class="btn-action-trigger outline-secondary-btn" style="text-decoration:none;">Register Now</a>
                    <a href="index.jsp" class="btn-action-trigger text-link-btn" style="color:#999; font-size:13px;">Browse Page 1 Again</a>
                </div>
            </div>
        </div>
    <% } %>

    <!-- 4. Client Side Cascading Script Triggers[cite: 1] -->
    <script>
        function loadPostOffices() {
            const dist = document.getElementById("districtSelect").value;
            const poSel = document.getElementById("postOfficeSelect");
            const areaSel = document.getElementById("areaSelect");
            
            poSel.innerHTML = "<option value=''>Select Post Office</option>";
            areaSel.innerHTML = "<option value=''>Select Area</option>";
            if (!dist) return;

            fetch("ListingServlet?action=getPostOffices&district=" + encodeURIComponent(dist))
                .then(res => res.json())
                .then(data => {
                    data.forEach(po => {
                        let opt = document.createElement("option");
                        opt.value = po; opt.textContent = po;
                        poSel.appendChild(opt);
                    });
                }).catch(err => console.error("Error linking post offices:", err));
        }

        function loadAreas() {
            const po = document.getElementById("postOfficeSelect").value;
            const areaSel = document.getElementById("areaSelect");
            
            areaSel.innerHTML = "<option value=''>Select Area</option>";
            if (!po) return;

            fetch("ListingServlet?action=getAreas&post_office=" + encodeURIComponent(po))
                .then(res => res.json())
                .then(data => {
                    data.forEach(a => {
                        let opt = document.createElement("option");
                        opt.value = a; opt.textContent = a;
                        areaSel.appendChild(opt);
                    });
                }).catch(err => console.error("Error linking area options:", err));
        }
    </script>
    <jsp:include page="_footer.jsp" />
</body>
</html>
