package com.roomlagbe.controller;

import com.roomlagbe.config.DBConnection;
import com.roomlagbe.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Collection;
import java.util.UUID;

@WebServlet("/ListingServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class ListingServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "getPostOffices":
                fetchPostOffices(request, response);
                break;
            case "getAreas":
                fetchAreas(request, response);
                break;
            case "approve":
                processAdApproval(request, response, "Ad running");
                break;
            case "reject":
                processAdApproval(request, response, "Closed");
                break;
            default:
                response.sendRedirect("index.jsp");
                break;
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            processAdInsertion(request, response);
        }
    }

    // Dynamic AJAX Cascading Dropdowns: Fetch matching post offices via specific query parameter strings
    private void fetchPostOffices(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        String district = request.getParameter("district");
        String query = "SELECT DISTINCT post_office FROM LOCATIONS WHERE district = ? ORDER BY post_office";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             PrintWriter out = response.getWriter()) {
            
            stmt.setString(1, district);
            try (ResultSet rs = stmt.executeQuery()) {
                StringBuilder json = new StringBuilder("[");
                while (rs.next()) {
                    json.append("\"").append(rs.getString("post_office")).append("\",");
                }
                if (json.length() > 1) json.setLength(json.length() - 1);
                json.append("]");
                out.print(json.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Dynamic AJAX Cascading Dropdowns: Fetch specific area parameter arrays matching targeted selection models
    private void fetchAreas(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        String postOffice = request.getParameter("post_office");
        String query = "SELECT DISTINCT area FROM LOCATIONS WHERE post_office = ? ORDER BY area";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             PrintWriter out = response.getWriter()) {
            
            stmt.setString(1, postOffice);
            try (ResultSet rs = stmt.executeQuery()) {
                StringBuilder json = new StringBuilder("[");
                while (rs.next()) {
                    json.append("\"").append(rs.getString("area")).append("\",");
                }
                if (json.length() > 1) json.setLength(json.length() - 1);
                json.append("]");
                out.print(json.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Process room ad insertions supporting flexible photo counts (1 to 5 uploads) using individual UUID row bindings
    private void processAdInsertion(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String insertAdSql = "INSERT INTO LISTINGS (poster_id, title, description, district, post_office, area, " +
            "holding_number_lane, preferred_religion, preferred_gender, preferred_smoking, num_rooms, available_rooms, " +
            "is_shared_room, has_attached_washroom, utility_electricity, utility_gas, utility_water, utility_internet, " +
            "utility_waste, current_roommates, current_male_count, current_female_count, current_third_count, rent, " +
            "utility_charge_type, utility_charge_amount, required_roommates) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(insertAdSql, new String[]{"listing_id"})) {
            
            conn.setAutoCommit(false); // Enable transactional integrity controls
            
            stmt.setInt(1, user.getUserId());
            stmt.setString(2, request.getParameter("title"));
            stmt.setString(3, request.getParameter("description"));
            stmt.setString(4, request.getParameter("district"));
            stmt.setString(5, request.getParameter("post_office"));
            stmt.setString(6, request.getParameter("area"));
            stmt.setString(7, request.getParameter("holding_number_lane"));
            stmt.setString(8, request.getParameter("preferred_religion"));
            stmt.setString(9, request.getParameter("preferred_gender"));
            stmt.setString(10, request.getParameter("preferred_smoking"));
            stmt.setInt(11, Integer.parseInt(request.getParameter("num_rooms")));
            stmt.setInt(12, Integer.parseInt(request.getParameter("available_rooms")));
            stmt.setInt(13, request.getParameter("is_shared_room") != null ? 1 : 0);
            stmt.setInt(14, request.getParameter("has_attached_washroom") != null ? 1 : 0);
            stmt.setInt(15, request.getParameter("utility_electricity") != null ? 1 : 0);
            stmt.setInt(16, request.getParameter("utility_gas") != null ? 1 : 0);
            stmt.setInt(17, request.getParameter("utility_water") != null ? 1 : 0);
            stmt.setInt(18, request.getParameter("utility_internet") != null ? 1 : 0);
            stmt.setInt(19, request.getParameter("utility_waste") != null ? 1 : 0);
            stmt.setInt(20, Integer.parseInt(request.getParameter("current_roommates")));
            stmt.setInt(21, Integer.parseInt(request.getParameter("current_male_count")));
            stmt.setInt(22, Integer.parseInt(request.getParameter("current_female_count")));
            stmt.setInt(23, Integer.parseInt(request.getParameter("current_third_count")));
            stmt.setDouble(24, Double.parseDouble(request.getParameter("rent")));
            stmt.setString(25, request.getParameter("utility_charge_type"));
            
            String utilAmt = request.getParameter("utility_charge_amount");
            if (utilAmt != null && !utilAmt.isEmpty()) {
                stmt.setDouble(26, Double.parseDouble(utilAmt));
            } else {
                stmt.setNull(26, java.sql.Types.NUMERIC);
            }
            stmt.setInt(27, Integer.parseInt(request.getParameter("required_roommates")));
            
            stmt.executeUpdate();
            
            // Retrieve generated identity tracking value smoothly using standard internal arrays
            int listingId = 0;
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    listingId = generatedKeys.getInt(1);
                }
            }
            
            // Multi-image upload parsing iteration loop handles image inputs flexibly
            Collection<Part> parts = request.getParts();
            String uploadPath = "D:/New Backup/Soft/RoomLagbe.com/src/main/webapp/uploads/listings";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();
            
            String insertPhotoSql = "INSERT INTO LISTING_PHOTOS (listing_id, photo_path) VALUES (?, ?)";
            try (PreparedStatement photoStmt = conn.prepareStatement(insertPhotoSql)) {
                for (Part part : parts) {
                    if (part.getName().equals("room_photos") && part.getSize() > 0) {
                        String origName = part.getSubmittedFileName();
                        String ext = origName.substring(origName.lastIndexOf("."));
                        String randomName = UUID.randomUUID().toString() + ext;
                        
                        part.write(uploadPath + File.separator + randomName);
                        
                        photoStmt.setInt(1, listingId);
                        photoStmt.setString(2, "/uploads/listings/" + randomName);
                        photoStmt.addBatch();
                    }
                }
                photoStmt.executeBatch();
            }
            
            conn.commit(); // Push structural operations downstream explicitly
            response.sendRedirect("mylistings.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    // Absorbed Administrator Action: Centralized dashboard processing tracking changes status directly here
    private void processAdApproval(HttpServletRequest request, HttpServletResponse response, String targetStatus) 
            throws IOException {
        
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
            return;
        }
        
        int listingId = Integer.parseInt(request.getParameter("id"));
        String query = "UPDATE LISTINGS SET status = ? WHERE listing_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, targetStatus);
            stmt.setInt(2, listingId);
            stmt.executeUpdate();
            
            response.sendRedirect("admin.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}