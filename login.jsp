<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Sign In</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .login-card { max-width: 400px; margin: 60px auto; padding: 25px; background: #fff; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .field-item { margin-bottom: 15px; }
        .field-item label { display: block; font-weight: bold; margin-bottom: 5px; color: #444; font-size: 14px; }
        .field-item input { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .alert-success { background: #e2f0d9; color: #385723; padding: 10px; border-radius: 4px; border: 1px solid #c3e6cb; margin-bottom: 15px; font-size: 13px; text-align: center; }
        .alert-error { background: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; border: 1px solid #f5c6cb; margin-bottom: 15px; font-size: 13px; text-align: center; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container">
        <div class="login-card">
            <h2 style="margin-top:0; text-align:center;">Sign In</h2>
            <p style="text-align:center; color:#777; font-size:13px; margin-top:-5px; margin-bottom:20px;">Access your student roommate hunting dashboard</p>

            <%-- Catch registration activation success statuses parameter flags dynamically --%>
            <% if ("account_verified".equals(request.getParameter("msg"))) { %>
                <div class="alert-success">🎉 Verification successful! You can now log in.</div>
            <% } else if ("password_reset_success".equals(request.getParameter("msg"))) { %>
                <div class="alert-success">🔑 Password updated. Use your new credentials to log in.</div>
            <% } %>

            <%-- Catch runtime errors passed back from the LoginServlet execution path --%>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="LoginServlet" method="POST">
                <div class="field-item">
                    <label>Email Address</label>
                    <input type="email" name="email" required placeholder="Ex: name@gmail.com">
                </div>

                <div class="field-item">
                    <label>Password</label>
                    <input type="password" name="password" required placeholder="Enter account password">
                </div>

                <input type="submit" value="Authenticate" style="width:100%; padding:10px; background:#007bff; color:#fff; border:none; font-weight:bold; cursor:pointer; border-radius:4px; margin-top:10px;">
            </form>

            <div style="margin-top:20px; text-align:center; font-size:13px; display:flex; justify-content:space-between;">
                <a href="forgotpassword.jsp" style="color:#666; text-decoration:none;">Forgot Password?</a>
                <a href="registration.jsp" style="color:#007bff; text-decoration:none; font-weight:bold;">Create Profile</a>
            </div>
        </div>
    </main>

    <jsp:include page="_footer.jsp" />
</body>
</html>