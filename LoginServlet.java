package com.roomlagbe.controller;

import com.roomlagbe.config.DBConnection;
import com.roomlagbe.model.User;
import com.roomlagbe.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email").trim();
        String password = request.getParameter("password");
        
        // ADDED: photo_path column added to the SELECT list
        String query = "SELECT user_id, full_name, password_hash, role, is_verified, is_blocked, photo_path " +
                       "FROM USERS WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int isVerified = rs.getInt("is_verified");
                    int isBlocked = rs.getInt("is_blocked");
                    
                    if (isVerified == 0) {
                        request.setAttribute("error", "Please verify your email via OTP first.");
                        request.getRequestDispatcher("verify.jsp?flow=register").forward(request, response);
                        return;
                    }
                    
                    if (isBlocked == 1) {
                        request.setAttribute("error", "Your account has been blocked by an administrator.");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                        return;
                    }
                    
                    String storedHash = rs.getString("password_hash");
                    // Verify the password using your hashing utility
                    if (PasswordUtil.checkPassword(password, storedHash)) {
                        
                        // Authentication successful! Create session object
                        HttpSession session = request.getSession(true);
                        
                        User user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setFullName(rs.getString("full_name"));
                        user.setEmail(email);
                        user.setRole(rs.getString("role"));
                        
                        // ADDED: Extract the file path string and bind it to the session user bean object
                        user.setPhotoPath(rs.getString("photo_path"));
                        
                        session.setAttribute("currentUser", user);
                        
                        // Branching Redirects based on user role
                        if ("admin".equalsIgnoreCase(user.getRole())) {
                            response.sendRedirect("admin.jsp");
                        } else {
                            response.sendRedirect("index.jsp");
                        }
                    } else {
                        request.setAttribute("error", "Invalid credentials provided.");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "Account matching this email does not exist.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}