<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.roomlagbe.config.DBConnection, com.roomlagbe.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int currentUserId = currentUser.getUserId();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - My Listings</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .dashboard-layout { max-width: 950px; margin: 30px auto; padding: 0 15px; }
        .dashboard-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #eee; padding-bottom: 15px; margin-bottom: 25px; }
        .own-ad-card { border: 1px solid #ddd; background: #fff; border-radius: 4px; padding: 20px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.02); }
        .ad-meta { display: flex; justify-content: space-between; align-items: flex-start; }
        .status-pill { padding: 4px 8px; font-size: 11px; font-weight: bold; border-radius: 3px; text-transform: uppercase; }
        .status-review { background: #fff3cd; color: #856404; }
        .status-running { background: #d4edda; color: #155724; }
        .status-closed { background: #e2e3e5; color: #383d41; }
        
        /* Interactive Expandable Applicant Segment Styling */
        .applicant-section { margin-top: 15px; padding-top: 15px; border-top: 1px dashed #ccc; display: none; }
        .applicant-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 15px; margin-top: 10px; }
        .applicant-card { background: #f9f9f9; border: 1px solid #e0e0e0; padding: 12px; border-radius: 4px; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container dashboard-layout">
        <div class="dashboard-header">
            <h2 style="margin:0; color:#333;">Your Posted Advertisements</h2>
            <a href="addlisting.jsp" class="btn" style="background:#007bff; color:#fff; text-decoration:none; padding:10px 18px; font-weight:bold; border:none; border-radius:4px;">+ Post New Ad</a>
        </div>

        <%
            String listingQuery = "SELECT * FROM LISTINGS WHERE poster_id = ? ORDER BY publish_date DESC";
            int listingCounter = 0;
            
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(listingQuery)) {
                
                stmt.setInt(1, currentUserId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        listingCounter++;
                        int listingId = rs.getInt("listing_id");
                        String title = rs.getString("title");
                        double rent = rs.getDouble("rent");
                        String area = rs.getString("area");
                        String status = rs.getString("status");
                        int reqRoommates = rs.getInt("required_roommates");
                        
                        String statusClass = "status-review";
                        if ("Ad running".equalsIgnoreCase(status)) statusClass = "status-running";
                        else if ("Closed".equalsIgnoreCase(status)) statusClass = "status-closed";
        %>
                        <div class="own-ad-card">
                            <div class="ad-meta">
                                <div>
                                    <h3 style="margin:0 0 5px 0; color:#222;"><%= title %></h3>
                                    <p style="margin:3px 0; color:#666; font-size:13px;"><strong>Location:</strong> <%= area %> | <strong>Rent:</strong> <%= rent %> BDT/month</p>
                                    <p style="margin:3px 0; color:#d32f2f; font-size:13px;"><strong>Seats Required:</strong> <%= reqRoommates %> slot(s) vacant</p>
                                </div>
                                <div style="text-align:right;">
                                    <span class="status-pill <%= statusClass %>"><%= status %></span>
                                    <div style="margin-top:15px;">
                                        <a href="editlisting.jsp?id=<%= listingId %>" class="btn" style="font-size:12px; padding:5px 10px; text-decoration:none; margin-right:5px;">Edit Details</a>
                                    </div>
                                </div>
                            </div>

                            <%-- Count outstanding applications tied to this listing --%>
                            <%
                                int applicantCount = 0;
                                String countSql = "SELECT COUNT(*) FROM APPLICATIONS WHERE listing_id = ? AND status = 'Pending'";
                                try (PreparedStatement countStmt = conn.prepareStatement(countSql)) {
                                    countStmt.setInt(1, listingId);
                                    try (ResultSet rsCount = countStmt.executeQuery()) {
                                        if (rsCount.next()) applicantCount = rsCount.getInt(1);
                                    }
                                }
                            %>

                            <div style="margin-top:15px;">
                                <button class="btn" style="font-size:12px; font-weight:bold; cursor:pointer;" onclick="toggleApplicantsBlock(<%= listingId %>)">
                                    Applicants (<%= applicantCount %> Pending) ↓
                                </button>
                            </div>

                            <%-- Applicant Reveal Module Subquery Node --%>
                            <div id="applicantsBlock_<%= listingId %>" class="applicant-section">
                                <h4 style="margin:0 0 10px 0; font-size:14px; color:#555;">Pending Room Connection Requests</h4>
                                <div class="applicant-grid">
                                    <%
                                        // Inner join statement extracting applicant profile details while excluding direct email/IDs
                                        String appSql = "SELECT a.application_id, u.full_name, u.gender, u.religion, u.birthdate, u.contact_number " +
                                                        "FROM APPLICATIONS a JOIN USERS u ON a.applicant_id = u.user_id " +
                                                        "WHERE a.listing_id = ? AND a.status = 'Pending'";
                                        
                                        try (PreparedStatement appStmt = conn.prepareStatement(appSql)) {
                                            appStmt.setInt(1, listingId);
                                            try (ResultSet rsApp = appStmt.executeQuery()) {
                                                int individualAppCounter = 0;
                                                while (rsApp.next()) {
                                                    individualAppCounter++;
                                                    int appId = rsApp.getInt("application_id");
                                                    String appName = rsApp.getString("full_name");
                                                    String appGender = rsApp.getString("gender");
                                                    String appReligion = rsApp.getString("religion");
                                                    String appPhone = rsApp.getString("contact_number");
                                                    
                                                    // Dynamic prefilled WhatsApp trigger text linking directly to the student
                                                    String encodedText = java.net.URLEncoder.encode("Hi " + appName + "! I'm contacting you from RoomLagbe.com regarding your roommate application for my room '" + title + "'...", "UTF-8");
                                    %>
                                                    <div class="applicant-card">
                                                        <strong style="font-size:14px; color:#111; display:block; margin-bottom:4px;"><%= appName %></strong>
                                                        <p style="margin:2px 0; font-size:12px; color:#555;">Gender: <%= appGender %> | Religion: <%= appReligion %></p>
                                                        
                                                        <div style="margin-top:10px; display:flex; gap:5px;">
                                                            <%-- Target Actions route out context variables directly to tracking layers --%>
                                                            <a href="ApplicationServlet?action=accept&appId=<%= appId %>" class="btn" style="background:#28a745; color:#fff; border:none; font-size:11px; padding:4px 8px; text-decoration:none; font-weight:bold;">Accept</a>
                                                            <a href="ApplicationServlet?action=reject&appId=<%= appId %>" class="btn" style="background:#dc3545; color:#fff; border:none; font-size:11px; padding:4px 8px; text-decoration:none; font-weight:bold;">Reject</a>
                                                            <a href="https://wa.me/<%= appPhone.replaceAll("[^0-9]", "") %>?text=<%= encodedText %>" target="_blank" class="btn" style="background:#25D366; color:#fff; border:none; font-size:11px; padding:4px 8px; text-decoration:none; font-weight:bold;">WhatsApp</a>
                                                        </div>
                                                    </div>
                                    <%
                                                }
                                                if (individualAppCounter == 0) {
                                                    out.println("<p style='font-size:13px; color:#888; margin:0;'>No outstanding matching applications currently tied to this property.</p>");
                                                }
                                            }
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
        <%
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }

            if (listingCounter == 0) {
        %>
                <div style="text-align:center; padding:50px; background:#fff; border:1px dashed #ccc; border-radius:4px; margin-top:20px; color:#666;">
                    <p style="margin:0; font-size:15px;">You have not published any accommodation room advertisements yet.</p>
                    <a href="addlisting.jsp" class="btn" style="display:inline-block; margin-top:15px; text-decoration:none;">Post Your First Room Ad</a>
                </div>
        <%
            }
        %>
    </main>

    <script>
        function toggleApplicantsBlock(id) {
            const block = document.getElementById("applicantsBlock_" + id);
            if (block.style.display === "block") {
                block.style.display = "none";
            } else {
                block.style.display = "block";
            }
        }
    </script>
    <jsp:include page="_footer.jsp" />
</body>
</html>