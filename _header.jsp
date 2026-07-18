<%-- _header.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.roomlagbe.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RoomLagbe.com - Elite Room Sharing Platform</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <%@ include file="_styles.jsp" %>
</head>
<body>

    <header class="header-nav">
        <div class="logo">
            <a href="<%= request.getContextPath() %>/ListingServlet?action=listAll">
                <img src="<%= request.getContextPath() %>/images/logo.png" 
                     alt="RoomLagbe Logo" 
                     class="brand-logo-img">
            </a>
        </div>
<%
    // Check if the request was forwarded by a servlet first
    String forwardUri = (String) request.getAttribute("javax.servlet.forward.request_uri");
    String uri = (forwardUri != null) ? forwardUri : request.getRequestURI();
    
    String currentPageName = uri.substring(uri.lastIndexOf("/") + 1);
    
    // If accessing root or arriving via ListingServlet query action feed, fall back to index.jsp
    if (currentPageName.isEmpty() || "/".equals(uri) || "ListingServlet".equalsIgnoreCase(currentPageName)) {
        currentPageName = "index.jsp";
    }
%>

<%-- Dynamic navigation link block --%>
<nav class="nav-links">
    <a href="<%= request.getContextPath() %>/ListingServlet?action=listAll" class="<%= "index.jsp".equals(currentPageName) ? "active" : "" %>">Home</a>
    <a href="<%= request.getContextPath() %>/mylistings.jsp" class="<%= "mylistings.jsp".equals(currentPageName) ? "active" : "" %>">My listings</a>
    <a href="<%= request.getContextPath() %>/applied.jsp" class="<%= "applied.jsp".equals(currentPageName) ? "active" : "" %>">Applied rooms</a>
    <a href="<%= request.getContextPath() %>/contact.jsp" class="<%= "contact.jsp".equals(currentPageName) ? "active" : "" %>">Contact us</a>
</nav>
       
        <div class="profile-trigger" id="profileTrigger">
            <% 
                if (currentUser != null && currentUser.getPhotoPath() != null && !currentUser.getPhotoPath().trim().isEmpty()) { 
                    String rawPhotoPath = currentUser.getPhotoPath();
                    String cleanPhotoUrl;
                    
                    // Prevent duplicate folder generation if the text already contains the storage directory prefix
                    if (rawPhotoPath.contains("uploads/")) {
                        cleanPhotoUrl = rawPhotoPath.startsWith("/") ? rawPhotoPath : "/" + rawPhotoPath;
                    } else {
                        cleanPhotoUrl = "/uploads/profiles/" + rawPhotoPath;
                    }
            %>
                <img src="<%= request.getContextPath() + cleanPhotoUrl %>" alt="Profile" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">
            <% } else { 
                String displayInitials = (currentUser != null) ? currentUser.getFullName().substring(0, Math.min(2, currentUser.getFullName().length())) : "GU";
            %>
                <div style="width:100%; height:100%; background:linear-gradient(135deg, var(--primary), var(--accent)); color:#ffffff; font-weight:700; font-size:0.85rem; display:flex; align-items:center; justify-content:center; text-transform:uppercase; letter-spacing:0.05em; border-radius:50%;">
                    <%= displayInitials %>
                </div>
            <% } %>
        </div>
    </header>

    <div class="sidebar-overlay" id="sidebarDrawer">
        <button class="sidebar-close" id="sidebarClose">&times;</button>
        
        <div class="sidebar-content" style="flex-grow: 1;">
            <% if (currentUser != null) { %>
                <div class="profile-info">
                    <% 
                        if (currentUser.getPhotoPath() != null && !currentUser.getPhotoPath().trim().isEmpty()) { 
                            String rawPhotoPath = currentUser.getPhotoPath();
                            String cleanPhotoUrl;
                            
                            if (rawPhotoPath.contains("uploads/")) {
                                cleanPhotoUrl = rawPhotoPath.startsWith("/") ? rawPhotoPath : "/" + rawPhotoPath;
                            } else {
                                cleanPhotoUrl = "/uploads/profiles/" + rawPhotoPath;
                            }
                    %>
                        <img src="<%= request.getContextPath() + cleanPhotoUrl %>" alt="User Avatar" class="profile-img">
                    <% } else { %>
                        <div style="width:84px; height:84px; margin:0 auto 1rem auto; border-radius:50%; background:linear-gradient(135deg, var(--primary), var(--accent)); color:#ffffff; font-weight:700; font-size:1.5rem; display:flex; align-items:center; justify-content:center; text-transform:uppercase; border:3px solid var(--primary-light);">
                            <%= currentUser.getFullName().substring(0, Math.min(2, currentUser.getFullName().length())) %>
                        </div>
                    <% } %>
                    <h3 style="color: var(--text-heading); font-weight:700;"><%= currentUser.getFullName() %></h3>
                    <p style="font-size:0.85rem; color:var(--text-muted);"><%= currentUser.getEmail() %></p>
                </div>
                <div class="sidebar-links">
                    <a href="<%= request.getContextPath() %>/mylistings.jsp">My listings</a>
                    <a href="<%= request.getContextPath() %>/applied.jsp">Applied rooms</a>
                    <% if ("admin".equals(currentUser.getRole())) { %>
                        <a href="<%= request.getContextPath() %>/admin.jsp" style="font-weight: 700; color: var(--primary);">Admin Dashboard</a>
                    <% } %>
                    
                    <!-- Form layout configuration to route POST safely to LogoutServlet -->
                    <form id="logoutForm" action="<%= request.getContextPath() %>/LogoutServlet" method="POST" style="display:none;"></form>
                    <a href="javascript:void(0);" onclick="document.getElementById('logoutForm').submit();" style="color: #ef4444;">Log out</a>
                </div>
            <% } else { %>
                <div class="profile-info">
                    <div style="width:84px; height:84px; margin:0 auto 1rem auto; border-radius:50%; background:var(--bg-neutral); color:var(--text-muted); font-weight:700; font-size:1.5rem; display:flex; align-items:center; justify-content:center;">?</div>
                    <h3 style="color: var(--text-heading); font-weight:700;">Welcome Student</h3>
                    <p style="margin-bottom: 2rem; font-size: 0.9rem; color: var(--text-muted);">Sign in to access premium room-sharing options.</p>
                    <a href="<%= request.getContextPath() %>/login.jsp" class="btn-view" style="display: block;">Sign In</a>
                </div>
            <% } %>
        </div>

        <div class="ad-placeholder ad-sidebar-drawer">
            Premium Ad Placement Slot
        </div>
    </div>

    <script>
        const drawer = document.getElementById('sidebarDrawer');
        document.getElementById('profileTrigger').addEventListener('click', () => drawer.classList.add('open'));
        document.getElementById('sidebarClose').addEventListener('click', () => drawer.classList.remove('open'));
    </script>
</body>
</html>