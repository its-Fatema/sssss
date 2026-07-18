package com.roomlagbe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.roomlagbe.config.DBConnection;
import com.roomlagbe.model.Listing;
import com.roomlagbe.model.User;

@WebServlet("/FilterServlet")
public class FilterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public FilterServlet() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Security Gate: Verify the person requesting this is an active administrator
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "viewQueue";
        }

        try {
            switch (action.toLowerCase()) {
                case "approve":
                    updateListingStatus(request, response, "Ad running");
                    break;
                case "reject":
                    updateListingStatus(request, response, "Rejected");
                    break;
                case "viewqueue":
                default:
                    showModerationQueue(request, response);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Database fault inside listing moderation filter subsystem.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }

    // Pipeline A: Fetch all listings that have an "In review" status label
    private void showModerationQueue(HttpServletRequest request, HttpServletResponse response) 
            throws SQLException, ServletException, IOException {
        
        List<Listing> pendingListings = new ArrayList<>();
        // Query targets listings stuck in the moderation review phase
        String query = "SELECT * FROM LISTINGS WHERE status = 'In review' ORDER BY listing_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Listing room = new Listing();
                room.setListingId(rs.getInt("listing_id"));
                //room.setUserId(rs.getInt("poster_id"));
                room.setTitle(rs.getString("title"));
                room.setDescription(rs.getString("description"));
                room.setRent(rs.getDouble("rent"));
                room.setDistrict(rs.getString("district"));
                room.setArea(rs.getString("area"));
                room.setPostOffice(rs.getString("post_office"));
                room.setHoldingNumberLane(rs.getString("holding_number_lane"));
                room.setPreferredGender(rs.getString("preferred_gender"));
                room.setRequiredRoommates(rs.getInt("required_roommates"));
                room.setStatus(rs.getString("status"));
                pendingListings.add(room);
            }
        }

        // Pass the array list straight down to the view canvas template
        request.setAttribute("pendingQueue", pendingListings);
        request.getRequestDispatcher("postfilter.jsp").forward(request, response);
    }

    // Pipeline B: Modify the advertisement data status based on admin interaction choice
 // Pipeline B: Modify the advertisement data status based on admin interaction choice
    private void updateListingStatus(HttpServletRequest request, HttpServletResponse response, String newStatus) 
            throws SQLException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            int listingId = Integer.parseInt(idParam.trim());
            String query = "UPDATE LISTINGS SET status = ? WHERE listing_id = ?";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(query)) {
                
                ps.setString(1, newStatus);
                ps.setInt(2, listingId);
                ps.executeUpdate(); // ⚡ Oracle automatically commits right here!
                
                // REMOVED: conn.commit(); <-- This was causing the ORA-17273 crash loop!
            }
        }
        
        // Refresh the page by redirecting cleanly back to the waiting queue dashboard view
        response.sendRedirect(request.getContextPath() + "/FilterServlet?action=viewQueue");
    }
}