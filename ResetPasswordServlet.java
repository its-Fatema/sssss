package com.roomlagbe.controller;

import com.roomlagbe.config.DBConnection;
import com.roomlagbe.util.EmailUtil;
import com.roomlagbe.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.Random;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {
    
    // Core distribution processor method handling incoming password replacement token request payloads
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email").trim();
        String otp = String.format("%06d", new Random().nextInt(999999));
        Timestamp expiry = new Timestamp(System.currentTimeMillis() + (1000 * 60 * 15));
        
        String sql = "UPDATE USERS SET verification_otp = ?, otp_expiry = ? WHERE email = ? AND is_verified = 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, otp);
            stmt.setTimestamp(2, expiry);
            stmt.setString(3, email);
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                EmailUtil.sendOTP(email, otp);
                request.getSession().setAttribute("pendingVerificationEmail", email);
                response.sendRedirect("verify.jsp?flow=recovery");
            } else {
                request.setAttribute("error", "No active verified account associated with this email.");
                request.getRequestDispatcher("forgotpassword.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
    
    // Target storage updater execution method processing new explicit input value credentials
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Boolean tokenVerified = (Boolean) request.getSession().getAttribute("otpVerifiedForReset");
        String email = (String) request.getSession().getAttribute("pendingVerificationEmail");
        String newPassword = request.getParameter("new_password");
        
        if (tokenVerified == null || !tokenVerified || email == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String updateSql = "UPDATE USERS SET password_hash = ?, verification_otp = NULL, otp_expiry = NULL WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(updateSql)) {
            
            stmt.setString(1, PasswordUtil.hashPassword(newPassword));
            stmt.setString(2, email);
            stmt.executeUpdate();
            
            // Clean dynamic security attribute states clean immediately
            request.getSession().removeAttribute("otpVerifiedForReset");
            request.getSession().removeAttribute("pendingVerificationEmail");
            
            response.sendRedirect("login.jsp?msg=password_reset_success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}