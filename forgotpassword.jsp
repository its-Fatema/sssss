<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Forgot Password</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .recovery-card { max-width: 400px; margin: 60px auto; padding: 25px; background: #fff; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .alert-error { background: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; border: 1px solid #f5c6cb; margin-bottom: 15px; font-size: 13px; text-align: center; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container">
        <div class="recovery-card">
            <h2 style="margin-top:0; text-align:center;">Password Recovery</h2>
            <p style="color:#666; font-size:13px; text-align:center; margin-bottom:20px;">Enter your verified email profile to distribute an authorization token code[cite: 1].</p>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- Use GET method to match the request dispatcher mapping bounds setup inside your ResetPasswordServlet[cite: 1] -->
            <form action="ResetPasswordServlet" method="GET">
                <div style="margin-bottom:15px;">
                    <label style="display:block; font-weight:bold; margin-bottom:5px; font-size:14px; color:#444;">Account Email</label>
                    <input type="email" name="email" required style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;" placeholder="Ex: username@gmail.com">
                </div>
                <input type="submit" value="Request Reset Token" style="width:100%; padding:10px; background:#007bff; color:#fff; border:none; font-weight:bold; cursor:pointer; border-radius:4px;">
            </form>
        </div>
    </main>

    <jsp:include page="_footer.jsp" />
</body>
</html>