<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Lock access to this page unless the token step passes validation checks
    Boolean tokenVerified = (Boolean) session.getAttribute("otpVerifiedForReset");
    if (tokenVerified == null || !tokenVerified) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Update Password</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .reset-card { max-width: 400px; margin: 60px auto; padding: 25px; background: #fff; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .error-msg { color:#c62828; font-size:12px; margin-top:4px; display:none; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container">
        <div class="reset-card">
            <h2 style="margin-top:0; text-align:center;">Set New Password</h2>
            <p style="color:#666; font-size:13px; text-align:center; margin-bottom:20px;">Token verified. Please configure your replacement account security parameters[cite: 1].</p>

            <form action="ResetPasswordServlet" method="POST" onsubmit="return validateMatchingPasswords()">
                <div style="margin-bottom:15px;">
                    <label style="display:block; font-weight:bold; margin-bottom:5px; font-size:14px; color:#444;">New Password</label>
                    <input type="password" id="newPass" name="new_password" required minlength="6" style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;">
                </div>

                <div style="margin-bottom:15px;">
                    <label style="display:block; font-weight:bold; margin-bottom:5px; font-size:14px; color:#444;">Confirm Password</label>
                    <input type="password" id="confirmPass" required style="width:100%; padding:8px; border:1px solid #ccc; border-radius:4px; box-sizing:border-box;">
                    <span id="matchError" class="error-msg">Password fields do not match. Please verify inputs.</span>
                </div>

                <input type="submit" value="Save Credentials" style="width:100%; padding:10px; background:#28a745; color:#fff; border:none; font-weight:bold; cursor:pointer; border-radius:4px;">
            </form>
        </div>
    </main>

    <script>
        function validateMatchingPasswords() {
            const p1 = document.getElementById("newPass").value;
            const p2 = document.getElementById("confirmPass").value;
            const error = document.getElementById("matchError");
            
            if (p1 !== p2) {
                error.style.display = "block";
                return false;
            }
            error.style.display = "none";
            return true;
        }
    </script>
    <jsp:include page="_footer.jsp" />
</body>
</html>