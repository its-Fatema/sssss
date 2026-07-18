<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Registration</title>
    <jsp:include page="_styles.jsp" />
    <style>
        /* Local structural helper alignments keeping form blocks clean */
        .registration-card { max-width: 500px; margin: 40px auto; padding: 25px; background: #fff; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .row-split { display: flex; gap: 15px; }
        .row-split .field-wrapper { flex: 1; }
        .field-wrapper { margin-bottom: 15px; }
        .field-wrapper label { display: block; font-weight: bold; margin-bottom: 5px; color: #333; font-size: 14px; }
        .field-wrapper input, .field-wrapper select { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .alert-box { background: #ffebee; color: #c62828; padding: 10px; border-radius: 4px; border: 1px solid #ffcdd2; margin-bottom: 15px; text-align: center; font-size: 13px; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container">
        <div class="registration-card">
            <h2 style="margin-top:0; text-align:center; color:#222;">Student Registration</h2>
            <p style="text-align:center; color:#666; font-size:13px; margin-top:-5px; margin-bottom:25px;">Enter your real credentials to build your room sharing profile</p>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-box">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <%-- Configured multi-part streaming handler to stream out your image avatar securely[cite: 1] --%>
            <form action="RegisterServlet" method="POST" enctype="multipart/form-data">
                
                <%-- Name Field Block: Strictly outlaws numbers or specific keys via standard patterns[cite: 1] --%>
                <div class="field-wrapper">
                    <label>Full Name</label>
                    <input type="text" 
                           name="full_name" 
                           required 
                           pattern="^[A-Za-z\s\.]+$" 
                           title="Full Name must only include standard alphabet letters, spaces, or periods. Numbers are blocked."
                           placeholder="Enter full name">
                </div>

                <%-- Domain restricted filter block: Strictly isolates to Gmail & Yahoo suffix spaces[cite: 1] --%>
                <div class="field-wrapper">
                    <label>Email Address</label>
                    <input type="email" 
                           name="email" 
                           required 
                           pattern="^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com)$" 
                           title="Registration requires a verified, valid @gmail.com or @yahoo.com email profile address."
                           placeholder="username@gmail.com / username@yahoo.com">
                </div>

                <%-- Upfront Password entry gathering field values before verification loops take over[cite: 1] --%>
                <div class="field-wrapper">
                    <label>Account Password</label>
                    <input type="password" 
                           name="password" 
                           required 
                           minlength="6"
                           placeholder="Create password (minimum 6 characters)">
                </div>

                <div class="row-split">
                    <div class="field-wrapper">
                        <label>Gender</label>
                        <select name="gender" required>
                            <option value="">Select</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Third">Third</option>
                        </select>
                    </div>

                    <div class="field-wrapper">
                        <label>Birthdate</label>
                        <input type="date" name="birthdate" required>
                    </div>
                </div>

                <div class="row-split">
                    <div class="field-wrapper">
                        <label>Religion</label>
                        <select name="religion" required>
                            <option value="">Select</option>
                            <option value="Islam">Islam</option>
                            <option value="Hinduism">Hinduism</option>
                            <option value="Buddhism">Buddhism</option>
                            <option value="Christianity">Christianity</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>

                    <div class="field-wrapper">
                        <label>WhatsApp Number</label>
                        <input type="tel" name="contact_number" required placeholder="e.g., 01XXXXXXXXX">
                    </div>
                </div>

                <%-- Dynamic binary file input upload avatar reference path[cite: 1] --%>
                <div class="field-wrapper" style="margin-top:5px;">
                    <label>Profile Picture Photo</label>
                    <input type="file" name="profile_photo" accept="image/png, image/jpeg, image/jpg" required>
                    <small style="color:#888; display:block; margin-top:3px;">Accepted file patterns: png, jpeg, or jpg extensions only.</small>
                </div>

                <input type="submit" value="Sign Up Now" style="width:100%; padding:10px; background:#007bff; color:#fff; border:none; font-size:15px; cursor:pointer; margin-top:15px; border-radius:4px;">
            </form>

            <div style="text-align:center; margin-top:20px; font-size:13px; color:#555;">
                Already have an active user account? <a href="login.jsp" style="color:#007bff; text-decoration:none; font-weight:bold;">Sign In here</a>
            </div>
        </div>
    </main>

    <jsp:include page="_footer.jsp" />
</body>
</html>