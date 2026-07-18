package com.roomlagbe.controller;

import com.roomlagbe.config.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

@WebServlet("/VerifyOTPServlet")
public class VerifyOTPServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String inputOtp = request.getParameter("otp");
        String flow = request.getParameter("flow"); // Expected parameters: 'register' or 'recovery'
        
        // Recover targeted execution scope email profile context from active session bounds
        String email = (String) request.getSession().getAttribute("pendingVerificationEmail");
        
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String query = "SELECT verification_otp, otp_expiry FROM USERS WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String savedOtp = rs.getString("verification_otp");
                    Timestamp expiry = rs.getTimestamp("otp_expiry");
                    
                    // Enforce timestamp lifespan limits
                    if (savedOtp.equals(inputOtp) && expiry.after(new Timestamp(System.currentTimeMillis()))) {
                        
                        if ("register".equalsIgnoreCase(flow)) {
                            // Registration verified path: Activate the account instantly
                            String activateSql = "UPDATE USERS SET is_verified = 1, verification_otp = NULL WHERE email = ?";
                            try (PreparedStatement updateStmt = conn.prepareStatement(activateSql)) {
                                updateStmt.setString(1, email);
                                updateStmt.executeUpdate();
                            }
                            request.getSession().removeAttribute("pendingVerificationEmail");
                            response.sendRedirect("login.jsp?msg=account_verified");
                            
                        } else if ("recovery".equalsIgnoreCase(flow)) {
                            // Recovery path: Advance token placeholder forward to update authorization screens
                            request.getSession().setAttribute("otpVerifiedForReset", true);
                            response.sendRedirect("resetpassword.jsp");
                        }
                    } else {
                        request.setAttribute("error", "Invalid or Expired OTP entry submitted.");
                        request.getRequestDispatcher("verify.jsp?flow=" + flow).forward(request, response);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}