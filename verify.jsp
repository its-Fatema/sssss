<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String flow = request.getParameter("flow");
    if (flow == null || flow.isEmpty()) flow = "register";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Verify OTP</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .otp-card { max-width: 400px; margin: 60px auto; padding: 25px; background: #fff; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); text-align: center; }
        .otp-input { width: 100%; padding: 12px; font-size: 20px; text-align: center; letter-spacing: 5px; font-weight: bold; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .alert-error { background: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; border: 1px solid #f5c6cb; margin-bottom: 15px; font-size: 13px; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container">
        <div class="otp-card">
            <h2 style="margin-top:0;">Email Verification</h2>
            <p style="color:#555; font-size:13px; line-height:1.4;">A 6-digit confirmation token code has been dispatched to your email address. It remains valid for 15 minutes[cite: 1].</p>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- Explicitly append the routing action parameters context token into the backend execution paths[cite: 1] -->
            <form action="VerifyOTPServlet?flow=<%= flow %>" method="POST" style="margin-top:20px;">
                <div style="margin-bottom:20px;">
                    <input type="text" name="otp" class="otp-input" required maxlength="6" pattern="\d{6}" title="Please submit exactly a 6-digit number token." placeholder="000000">
                </div>
                <input type="submit" value="Confirm Token Code" style="width:100%; padding:10px; background:#007bff; color:#fff; border:none; font-weight:bold; cursor:pointer; border-radius:4px;">
            </form>
        </div>
    </main>

    <jsp:include page="_footer.jsp" />
</body>
</html>