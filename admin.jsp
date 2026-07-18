<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.roomlagbe.config.DBConnection, com.roomlagbe.model.User" %>
<%
    // Enforce administrative view security blocks
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Admin Dashboard</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .admin-layout { max-width: 950px; margin: 30px auto; padding: 0 15px; }
        .approval-table { width: 100%; border-collapse: collapse; margin-top: 20px; background: #fff; border: 1px solid #ddd; }
        .approval-table th, .approval-table td { padding: 12px; border: 1px solid #ddd; text-align: left; font-size: 14px; }
        .approval-table th { background: #f4f4f4; font-weight: bold; color:#333; }
        .action-link { padding: 4px 8px; border-radius: 3px; font-size: 12px; font-weight: bold; text-decoration: none; margin-right: 5px; }
        .approve-trigger { background: #28a745; color: #fff; }
        .reject-trigger { background: #dc3545; color: #fff; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container admin-layout">
        <h2 style="margin-top:0; color:#222; border-bottom:2px solid #eaeaea; padding-bottom:8px;">Administrative Operations Dashboard</h2>
        <p style="color:#666; font-size:13px; margin-top:-5px;">Audit posted accommodations and push pending listings onto the home search feed stream[cite: 1].</p>

        <h3 style="margin-top:30px; margin-bottom:10px;">Pending Room Advertisements</h3>
        <table class="approval-table">
            <thead>
                <tr>
                    <th>Ad Title</th>
                    <th>Location Area</th>
                    <th>Rent (BDT)</th>
                    <th>Poster Context</th>
                    <th>Operations</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // Load only listings holding standard 'In review' statuses[cite: 1]
                    String query = "SELECT l.listing_id, l.title, l.area, l.rent, u.full_name " +
                                   "FROM LISTINGS l JOIN USERS u ON l.poster_id = u.user_id " +
                                   "WHERE l.status = 'In review' ORDER BY l.publish_date ASC";

                    int pendingCounter = 0;
                    try (Connection conn = DBConnection.getConnection();
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery(query)) {
                        
                        while (rs.next()) {
                            pendingCounter++;
                            int id = rs.getInt("listing_id");
                            String title = rs.getString("title");
                            String areaName = rs.getString("area");
                            double rent = rs.getDouble("rent");
                            String userName = rs.getString("full_name");
                %>
                            <tr>
                                <td><strong><%= title %></strong></td>
                                <td><%= areaName %></td>
                                <td><%= rent %> BDT</td>
                                <td><%= userName %></td>
                                <td>
                                    <!-- Explicit action routing redirects straight to ListingServlet[cite: 1] -->
                                    <a href="ListingServlet?action=approve&id=<%= id %>" class="action-link approve-trigger">Approve Ad</a>
                                    <a href="ListingServlet?action=reject&id=<%= id %>" class="action-link reject-trigger">Reject/Block</a>
                                </td>
                            </tr>
                <%
                        }
                    } catch (Exception e) { e.printStackTrace(); }

                    if (pendingCounter == 0) {
                        out.println("<tr><td colspan='5' style='text-align:center; padding:20px; color:#777;'>There are currently no pending room ads awaiting review.</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </main>

    <jsp:include page="_footer.jsp" />
</body>
</html>