package com.roomlagbe.controller;

import com.roomlagbe.config.DBConnection;
import com.roomlagbe.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/ApplicationServlet")
public class ApplicationServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int listingId = Integer.parseInt(request.getParameter("listing_id"));
        int applicantId = user.getUserId();
        
        // Critical Trap Prevention Query Check: Pull the poster identification signature immediately
        String verifyPosterQuery = "SELECT poster_id FROM LISTINGS WHERE listing_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement verifyStmt = conn.prepareStatement(verifyPosterQuery)) {
            
            verifyStmt.setInt(1, listingId);
            try (ResultSet rs = verifyStmt.executeQuery()) {
                if (rs.next()) {
                    int posterId = rs.getInt("poster_id");
                    
                    // Enforce structural boundary rules: Abort self applications instantly
                    if (posterId == applicantId) {
                        response.sendRedirect("viewlisting.jsp?id=" + listingId + "&error=self_apply_forbidden");
                        return;
                    }
                }
            }
            
            // Execute room search application placement cleanly inside target storage layers
            String applySql = "INSERT INTO APPLICATIONS (listing_id, applicant_id, status) VALUES (?, ?, 'Pending')";
            try (PreparedStatement applyStmt = conn.prepareStatement(applySql)) {
                applyStmt.setInt(1, listingId);
                applyStmt.setInt(2, applicantId);
                applyStmt.executeUpdate();
            }
            
            response.sendRedirect("applied.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}