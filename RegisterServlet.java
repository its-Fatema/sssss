package com.roomlagbe.controller;

import com.roomlagbe.config.DBConnection;
import com.roomlagbe.util.EmailUtil;
import com.roomlagbe.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.Random;
import java.util.UUID;

@WebServlet("/RegisterServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB cache boundary
    maxFileSize = 1024 * 1024 * 10,       // 10MB maximum file size limit
    maxRequestSize = 1024 * 1024 * 50     // 50MB maximum transaction ceiling
)
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String fullName = request.getParameter("full_name");
            String email = request.getParameter("email").trim();
            String password = request.getParameter("password");
            String gender = request.getParameter("gender");
            String birthdateStr = request.getParameter("birthdate"); // Expected: YYYY-MM-DD
            String religion = request.getParameter("religion");
            String contactNumber = request.getParameter("contact_number");
            
            // Generate UUID to safely rename the user profile picture icon
         // Generate UUID to safely rename the user profile picture icon
            Part filePart = request.getPart("profile_photo");
            String originalName = filePart.getSubmittedFileName();
            String fileExt = originalName.substring(originalName.lastIndexOf("."));
            String uniqueFileName = UUID.randomUUID().toString() + fileExt;

            // 1. DYNAMIC MATCHING: Get the real runtime path of the running application container
            // This points directly inside Tomcat's temporary running deployment workspace
            String appBasePath = getServletContext().getRealPath(""); 
            String uploadPath = appBasePath + File.separator + "uploads" + File.separator + "profiles";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs(); // Automatically generates the /uploads/profiles structural tree inside the running app
            }

            // 2. Write the binary file data directly out to the runtime disk layout
            filePart.write(uploadPath + File.separator + uniqueFileName);

            // 3. DATABASE RECORDING: Save the relative asset route path
            // This guarantees that currentUser.getPhotoPath() returns exactly "/uploads/profiles/filename.ext"
            String dbSavedPhotoPath = "/uploads/profiles/" + uniqueFileName;
            
            // Prepare unverified account primitives
            String passwordHash = PasswordUtil.hashPassword(password);
            String otp = String.format("%06d", new Random().nextInt(999999));
            Timestamp expiry = new Timestamp(System.currentTimeMillis() + (1000 * 60 * 15)); // Valid for 15 Mins
            
            String sql = "INSERT INTO USERS (full_name, email, password_hash, gender, birthdate, " +
                         "religion, contact_number, photo_path, role, is_verified, is_blocked, " +
                         "verification_otp, otp_expiry) VALUES (?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, 'user', 0, 0, ?, ?)";
            
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setString(1, fullName);
                stmt.setString(2, email);
                stmt.setString(3, passwordHash);
                stmt.setString(4, gender);
                stmt.setString(5, birthdateStr);
                stmt.setString(6, religion);
                stmt.setString(7, contactNumber);
                stmt.setString(8, dbSavedPhotoPath);
                stmt.setString(9, otp);
                stmt.setTimestamp(10, expiry);
                
                stmt.executeUpdate();
                
                // Fire out the verification email dispatch
                EmailUtil.sendOTP(email, otp);
                
                // Store registration context cleanly for OTP target lookups
                request.getSession().setAttribute("pendingVerificationEmail", email);
                response.sendRedirect("verify.jsp?flow=register");
            }
            
        } catch (Exception e) {
            e.printStackTrace(); // Prints the exact Oracle error down into the IDE terminal background
            request.setAttribute("error", "Database conflict or registration fallback failure: " + e.getMessage());
            request.getRequestDispatcher("registration.jsp").forward(request, response);
        }
    }
}