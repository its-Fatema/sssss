<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.roomlagbe.config.DBConnection, com.roomlagbe.model.User" %>
<%
    // Restrict access strictly to logged-in users.
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
    <title>RoomLagbe.com - Applied Rooms</title>
    <jsp:include page="_styles.jsp" />
    <style>
        /* Scoped styling for the applied history view dashboard */
        .dashboard-container { max-width: 850px; margin: 30px auto; padding: 0 15px; }
        .app-history-card { display: flex; justify-content: space-between; align-items: center; padding: 18px; border: 1px solid #ddd; background: #fff; margin-bottom: 15px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.03); }
        
        /* Dynamic Status Badges matching your table check constraints */
        .badge { padding: 5px 10px; font-size: 12px; font-weight: bold; border-radius: 3px; text-transform: uppercase; display: inline-block; }
        .badge-pending { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .badge-confirmed { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .badge-rejected { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .badge-cancelled { background: #e2e3e5; color: #383d41; border: 1px solid #d6d8db; }
        
        .room-meta-info h4 { margin: 0 0 6px 0; color: #222; font-size: 16px; }
        .room-meta-info p { margin: 3px 0; color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container dashboard-container">
        <h2 style="margin-top:0; border-bottom: 2px solid #eaeaea; padding-bottom:10px; color:#333;">Your Room Applications</h2>
        <p style="color:#777; font-size:13px; margin-top:-5px; margin-bottom:25px;">Track roommate matching requests and finalize ongoing rent deals.</p>

        <%
            // Inner join query linking tracking references across models dynamically
            String query = "SELECT a.application_id, a.status as app_status, a.applied_date, " +
                           "a.poster_accepted, a.applicant_accepted, l.listing_id, l.title, l.area, l.rent " +
                           "FROM APPLICATIONS a " +
                           "JOIN LISTINGS l ON a.listing_id = l.listing_id " +
                           "WHERE a.applicant_id = ? " +
                           "ORDER BY a.applied_date DESC";

            int appCounter = 0;
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(query)) {
                
                stmt.setInt(1, currentUserId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        appCounter++;
                        int id = rs.getInt("listing_id");
                        String title = rs.getString("title");
                        String area = rs.getString("area");
                        double rent = rs.getDouble("rent");
                        String appStatus = rs.getString("app_status");
                        String date = rs.getDate("applied_date").toString();
                        int posterAccepted = rs.getInt("poster_accepted");
                        int applicantAccepted = rs.getInt("applicant_accepted");
                        
                        // Select accurate badge style matching the schema parameters[cite: 1]
                        String badgeClass = "badge-pending";
                        if ("Deal Confirmed".equalsIgnoreCase(appStatus)) badgeClass = "badge-confirmed";
                        else if ("Rejected".equalsIgnoreCase(appStatus)) badgeClass = "badge-rejected";
                        else if ("Cancelled".equalsIgnoreCase(appStatus)) badgeClass = "badge-cancelled";
        %>
                        <div class="app-history-card">
                            <div class="room-meta-info">
                                <h4><%= title %></h4>
                                <p><strong>Location Address:</strong> <%= area %> | <strong>Rent:</strong> <%= rent %> BDT</p>
                                <p style="color:#999; font-size:12px;">Submitted on: <%= date %></p>
                                
                                <%-- Render progress notifications if the poster has accepted but applicant hasn't confirmed yet --%>
                                <% if ("Pending".equalsIgnoreCase(appStatus) && posterAccepted == 1 && applicantAccepted == 0) { %>
                                    <div style="margin-top:8px; font-size:12px; color:#155724; background:#d4edda; padding:6px; border-radius:3px; display:inline-block; font-weight:bold;">
                                        🎉 The poster accepted your request! Please view the ad details to confirm the final deal.
                                    </div>
                                <% } %>
                            </div>
                            
                            <div style="text-align: right; display:flex; flex-direction:column; gap:10px; align-items:flex-end;">
                                <span class="badge <%= badgeClass %>"><%= appStatus %></span>
                                <a href="viewlisting.jsp?id=<%= id %>" class="btn" style="font-size:12px; padding:6px 12px; text-decoration:none;">View Property</a>
                            </div>
                        </div>
        <%
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }

            if (appCounter == 0) {
        %>
                <div style="text-align:center; padding:40px; border:1px dashed #ccc; background:#fff; border-radius:4px; color:#666;">
                    <p style="margin:0; font-size:15px;">You have not applied for any shared rooms or hostels yet.</p>
                    <a href="index.jsp" class="btn" style="display:inline-block; margin-top:15px; text-decoration:none;">Browse Available Rooms</a>
                </div>
        <%
            }
        %>
    </main>

    <jsp:include page="_footer.jsp" />
</body>
</html>