<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.roomlagbe.config.DBConnection, com.roomlagbe.model.User" %>
<%
    // Ensure the incoming listing ID exists safely
    String listingIdParam = request.getParameter("id");
    if (listingIdParam == null || listingIdParam.isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }
    int targetListingId = Integer.parseInt(listingIdParam);

    // Identify current user context status
    User currentUser = (User) session.getAttribute("currentUser");
    int currentUserId = (currentUser != null) ? currentUser.getUserId() : -1;

    // Database tracking placeholders
    String title = "", description = "", district = "", postOffice = "", area = "", holdingNumber = "";
    String prefReligion = "", prefGender = "", prefSmoking = "", utilChargeType = "", status = "";
    double rent = 0.0;
    Double utilChargeAmt = null;
    int numRooms = 0, availRooms = 0, isShared = 0, hasWashroom = 0;
    int elec = 0, gas = 0, water = 0, internet = 0, waste = 0;
    int totalRoommates = 0, maleCount = 0, femaleCount = 0, thirdCount = 0, reqRoommates = 0;
    int posterId = -1;
    String posterName = "", posterPhone = "";

    // Load master accommodation data details via explicit structural inner joins
    String mainQuery = "SELECT l.*, u.full_name, u.contact_number FROM LISTINGS l " +
                       "JOIN USERS u ON l.poster_id = u.user_id WHERE l.listing_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(mainQuery)) {
        
        stmt.setInt(1, targetListingId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                posterId = rs.getInt("poster_id");
                title = rs.getString("title");
                description = rs.getString("description");
                district = rs.getString("district");
                postOffice = rs.getString("post_office");
                area = rs.getString("area");
                holdingNumber = rs.getString("holding_number_lane");
                prefReligion = rs.getString("preferred_religion");
                prefGender = rs.getString("preferred_gender");
                prefSmoking = rs.getString("preferred_smoking");
                numRooms = rs.getInt("num_rooms");
                availRooms = rs.getInt("available_rooms");
                isShared = rs.getInt("is_shared_room");
                hasWashroom = rs.getInt("has_attached_washroom");
                elec = rs.getInt("utility_electricity");
                gas = rs.getInt("utility_gas");
                water = rs.getInt("utility_water");
                internet = rs.getInt("utility_internet");
                waste = rs.getInt("utility_waste");
                totalRoommates = rs.getInt("current_roommates");
                maleCount = rs.getInt("current_male_count");
                femaleCount = rs.getInt("current_female_count");
                thirdCount = rs.getInt("current_third_count");
                rent = rs.getDouble("rent");
                utilChargeType = rs.getString("utility_charge_type");
                
                double amt = rs.getDouble("utility_charge_amount");
                if (!rs.wasNull()) utilChargeAmt = amt;
                
                status = rs.getString("status");
                reqRoommates = rs.getInt("required_roommates");
                posterName = rs.getString("full_name");
                posterPhone = rs.getString("contact_number");
            } else {
                response.sendRedirect("index.jsp");
                return;
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Check if the current viewer has already applied to this specific room ad
    boolean alreadyApplied = false;
    if (currentUser != null) {
        String appCheckSql = "SELECT COUNT(*) FROM APPLICATIONS WHERE listing_id = ? AND applicant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(appCheckSql)) {
            checkStmt.setInt(1, targetListingId);
            checkStmt.setInt(2, currentUserId);
            try (ResultSet rsCheck = checkStmt.executeQuery()) {
                if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                    alreadyApplied = true;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - View Room</title>
    <jsp:include page="_styles.jsp" />
    <style>
        /* Scoped styles optimized exclusively for the viewlisting.jsp detail split elements */
        .detail-split-layout { display: flex; gap: 25px; margin: 20px 0; align-items: flex-start; }
        .gallery-column { flex: 1.2; max-width: 550px; }
        .specifications-column { flex: 1; background: #fff; padding: 20px; border: 1px solid #ddd; border-radius: 4px; }
        
        /* Grid setup for managing multi-photo ad outputs dynamically */
        .photo-gallery-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 10px; margin-top: 10px; }
        .main-display-photo { width: 100%; height: 320px; object-fit: cover; border: 1px solid #ddd; border-radius: 4px; cursor: pointer; }
        .gallery-thumb-img { width: 100%; height: 80px; object-fit: cover; border: 1px solid #ccc; border-radius: 4px; cursor: pointer; opacity: 0.8; transition: opacity 0.2s; }
        .gallery-thumb-img:hover { opacity: 1; border-color: #007bff; }
        
        .spec-box { background: #f9f9f9; padding: 12px; margin-bottom: 15px; border-radius: 4px; border-left: 4px solid #007bff; }
        .utility-tag { display: inline-block; padding: 4px 8px; margin: 3px; background: #e2f0d9; color: #385723; font-size: 12px; font-weight: bold; border-radius: 3px; }
        .utility-tag.disabled { background: #f2f2f2; color: #a6a6a6; }
        
        /* Interactive full screen image modal popup styling wrappers */
        .img-modal-backdrop { position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.85); display:none; align-items:center; justify-content:center; z-index:99999; }
        .img-modal-backdrop img { max-width: 90%; max-height: 90%; border-radius: 4px; box-shadow: 0 0 15px rgba(255,255,255,0.2); }
        .ad-placeholder-h { width: 100%; height: 90px; background: #f0f0f0; display: flex; align-items: center; justify-content: center; margin: 15px 0; border: 1px dashed #bbb; font-size: 11px; color: #777; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <div class="container detail-split-layout">
        
        <%-- LEFT SECTION: Dynamic multi-photo gallery engine[cite: 1] --%>
        <div class="gallery-column">
            <%
                int imageCount = 0;
                String firstPhotoPath = "";
                
                // Track down multiple file records associated with current target listing
                String photoQuery = "SELECT photo_path FROM LISTING_PHOTOS WHERE listing_id = ? ORDER BY photo_id";
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement photoStmt = conn.prepareStatement(photoQuery)) {
                    photoStmt.setInt(1, targetListingId);
                    try (ResultSet rsPhoto = photoStmt.executeQuery()) {
            %>
                        <div class="photo-viewer-canvas">
            <%
                            while (rsPhoto.next()) {
                                imageCount++;
                                String path = rsPhoto.getString("photo_path");
                                if (imageCount == 1) {
                                    firstPhotoPath = path;
            %>
                                    <img src="<%= request.getContextPath() + path %>" id="masterViewPhoto" class="main-display-photo" alt="Main room view" onclick="popFullscreenImage(this.src)">
                                    <div class="photo-gallery-grid">
            <%
                                }
            %>
                                <img src="<%= request.getContextPath() + path %>" class="gallery-thumb-img" alt="Gallery preview photo" onclick="document.getElementById('masterViewPhoto').src = this.src">
            <%
                            }
                            if (imageCount == 0) {
                                out.println("<img src='images/room-placeholder.png' class='main-display-photo' alt='No photos uploaded'>");
                            } else {
            %>
                                    </div> <%-- Close photo-gallery-grid --%>
            <%
                            }
            %>
                        </div> <%-- Close photo-viewer-canvas --%>
            <%
                    }
                } catch (Exception e) { e.printStackTrace(); }
            %>

            <%-- Inline Horizontal Ad Space located right beneath the visual grid framework[cite: 1] --%>
            <div class="ad-placeholder-h">
                <strong>[Horizontal Advertisement Banner Space Below Photo Gallery]</strong>
            </div>

            <div style="margin-top:20px; padding:10px; border-top:1px solid #eee;">
                <h3>Description</h3>
                <p style="line-height:1.6; color:#444; white-space: pre-wrap;"><%= description %></p>
            </div>
        </div>

        <%-- RIGHT SECTION: Structural room parameters dashboard --%>
        <div class="specifications-column">
            <h2 style="margin-top:0; color:#222;"><%= title %></h2>
            <div style="font-size: 20px; font-weight: bold; color: #2e7d32; margin-bottom: 15px;"><%= rent %> BDT / Month</div>
            
            <div class="spec-box">
                <strong>Address Context:</strong><br>
                <%= holdingNumber %>, <%= area %>, PO: <%= postOffice %>, <%= district %>
            </div>

            <h4 style="margin-bottom:8px;">Roommate Specifications</h4>
            <table style="width:100%; border-collapse: collapse; font-size:13px; margin-bottom:15px;">
                <tr><td style="padding:5px 0; color:#666;">Preferred Gender:</td><td style="font-weight:bold;"><%= prefGender %></td></tr>
                <tr><td style="padding:5px 0; color:#666;">Preferred Religion:</td><td style="font-weight:bold;"><%= prefReligion %></td></tr>
                <tr><td style="padding:5px 0; color:#666;">Smoking Habits:</td><td style="font-weight:bold;"><%= prefSmoking %></td></tr>
            </table>

            <h4 style="margin-bottom:8px;">Property Overview</h4>
            <table style="width:100%; border-collapse: collapse; font-size:13px; margin-bottom:15px;">
                <tr><td style="padding:5px 0; color:#666;">Total Rooms / Available:</td><td style="font-weight:bold;"><%= numRooms %> Rooms / <%= availRooms %> Vacant</td></tr>
                <tr><td style="padding:5px 0; color:#666;">Shared Room Type:</td><td style="font-weight:bold;"><%= (isShared==1)?"Yes (Shared Space)":"No (Private Single)" %></td></tr>
                <tr><td style="padding:5px 0; color:#666;">Attached Washroom:</td><td style="font-weight:bold;"><%= (hasWashroom==1)?"Available":"Not Available" %></td></tr>
                <tr><td style="padding:5px 0; color:#666;">Required Roommates:</td><td style="font-weight:bold; color:#d32f2f;"><%= reqRoommates %> Seat(s) Remaining</td></tr>
            </table>

            <h4 style="margin-bottom:5px;">Current Occupant Composition</h4>
            <p style="font-size:12px; color:#666; margin:0 0 8px 0;">Total Current Roommates: <strong><%= totalRoommates %></strong></p>
            <div style="font-size:12px; background:#eee; padding:8px; border-radius:4px; margin-bottom:15px;">
                Male: <strong><%= maleCount %></strong> | Female: <strong><%= femaleCount %></strong> | Third: <strong><%= thirdCount %></strong>
            </div>

            <h4 style="margin-bottom:8px;">Included Utilities</h4>
            <div style="margin-bottom:15px;">
                <span class="utility-tag <%= (elec==1)?"":"disabled" %>">Electricity</span>
                <span class="utility-tag <%= (gas==1)?"":"disabled" %>">Gas</span>
                <span class="utility-tag <%= (water==1)?"":"disabled" %>">Water</span>
                <span class="utility-tag <%= (internet==1)?"":"disabled" %>">Internet</span>
                <span class="utility-tag <%= (waste==1)?"":"disabled" %>">Waste Disposal</span>
            </div>

            <h4 style="margin-bottom:8px;">Utility Fees Allocation</h4>
            <p style="font-size:13px; margin: 0 0 20px 0;">
                Type: <strong><%= utilChargeType %></strong> 
                <%= ("Excluded".equalsIgnoreCase(utilChargeType) && utilChargeAmt != null) ? " (Additional " + utilChargeAmt + " BDT)" : "" %>
            </p>

            <div style="border-top: 1px solid #eee; padding-top:20px;">
                
                <%-- 1. WhatsApp Integration Node Trigger[cite: 1] --%>
                <% 
                    String encodedMsg = java.net.URLEncoder.encode(
                        "Hi " + posterName + "! I'm contacting you regarding your room sharing advertisement '" + title + "' posted on RoomLagbe.com. Is it still available?", 
                        "UTF-8"
                    );
                %>
                <a href="https://wa.me/<%= posterPhone.replaceAll("[^0-9]", "") %>?text=<%= encodedMsg %>" 
                   target="_blank" 
                   class="btn" 
                   style="background:#25D366; color:#fff; border:none; text-decoration:none; display:block; text-align:center; padding:10px; font-weight:bold; margin-bottom:10px;">
                   Chat via WhatsApp
                </a>

                <%-- 2. Self-Application UI Block Logic Rules[cite: 1] --%>
                <% if (currentUserId == -1) { %>
                    <p style="font-size:12px; color:#d32f2f; text-align:center;">Please <a href="login.jsp">Sign In</a> to place applications for this accommodation.</p>
                <% } else if (currentUserId == posterId) { %>
                    <div style="background:#fff3cd; color:#856404; padding:10px; border-radius:4px; font-size:13px; text-align:center; font-weight:bold;">
                        This room ad belongs to you.
                    </div>
                <% } else if (alreadyApplied) { %>
                    <div style="background:#e2f0d9; color:#385723; padding:10px; border-radius:4px; font-size:13px; text-align:center; font-weight:bold;">
                        Application Submitted Successfully
                    </div>
                <% } else if ("Closed".equalsIgnoreCase(status)) { %>
                    <div style="background:#f8d7da; color:#721c24; padding:10px; border-radius:4px; font-size:13px; text-align:center; font-weight:bold;">
                        This ad execution status is closed.
                    </div>
                <% } else { %>
                    <form action="ApplicationServlet" method="POST">
                        <input type="hidden" name="listing_id" value="<%= targetListingId %>">
                        <input type="submit" value="Apply for Room Sharing" style="width:100%; padding:10px; background:#007bff; color:#fff; border:none; font-weight:bold; cursor:pointer;">
                    </form>
                <% } %>
            </div>
        </div>
    </div>

    <%-- Full-screen modal overlay wrapper targeting click magnification loops[cite: 1] --%>
    <div id="fullscreenOverlayModal" class="img-modal-backdrop" onclick="this.style.display='none'">
        <img id="fullscreenTargetImg" src="" alt="Magnified perspective preview">
    </div>

    <script>
        // Triggers the minimalist modal element visibility states
        function popFullscreenImage(srcString) {
            document.getElementById("fullscreenTargetImg").src = srcString;
            document.getElementById("fullscreenOverlayModal").style.display = "flex";
        }
    </script>
    <jsp:include page="_footer.jsp" />
</body>
</html>