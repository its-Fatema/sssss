package com.roomlagbe.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import com.roomlagbe.config.DBConnection;
import com.roomlagbe.model.User;

@WebServlet("/AddListingServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB threshold
    maxFileSize = 1024 * 1024 * 20,       // 20MB max size per image file
    maxRequestSize = 1024 * 1024 * 100    // 100MB max total request size
)
public class AddListingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String IMAGE_PATH_PREFIX = "uploads/listings/";

    public AddListingServlet() {
        super();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // -----------------------------------------------------------------
        // PHASE 1: SESSION VERIFICATION
        // -----------------------------------------------------------------
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User currentUser = (User) session.getAttribute("currentUser");
        int posterId = currentUser.getUserId(); 

        // -----------------------------------------------------------------
        // PHASE 2: PARSE PARAMETERS & CONVERT TYPES
        // -----------------------------------------------------------------
        String title = request.getParameter("title") != null ? request.getParameter("title").trim() : "";
        String description = request.getParameter("description") != null ? request.getParameter("description").trim() : "";
        
        String district = request.getParameter("district") != null ? request.getParameter("district").trim() : "";
        String postOffice = request.getParameter("postOffice") != null ? request.getParameter("postOffice").trim() : "";
        String area = request.getParameter("area") != null ? request.getParameter("area").trim() : "";
        String holdingNumberLane = request.getParameter("holdingNumberLane") != null ? request.getParameter("holdingNumberLane").trim() : "";
        
        String preferredReligion = request.getParameter("preferredReligion") != null ? request.getParameter("preferredReligion").trim() : "Any";
        String preferredGender = request.getParameter("preferredGender") != null ? request.getParameter("preferredGender").trim() : "Any";
        String preferredSmoking = request.getParameter("preferredSmoking") != null ? request.getParameter("preferredSmoking").trim() : "Non-smoking";
        
        String utilityChargeType = request.getParameter("utilityChargeType") != null ? request.getParameter("utilityChargeType").trim() : "Included";
        
        double rent = parseDoubleOrDefault(request.getParameter("rent"), 0.0);
        double utilityChargeAmount = parseDoubleOrDefault(request.getParameter("utilityChargeAmount"), 0.0);
        
        int numRooms = parseIntOrDefault(request.getParameter("numRooms"), 1);
        int availableRooms = parseIntOrDefault(request.getParameter("availableRooms"), 1);
        int requiredRoommates = parseIntOrDefault(request.getParameter("requiredRoommates"), 0);
        int currentRoommates = parseIntOrDefault(request.getParameter("currentRoommates"), 0);
        
        int currentMaleCount = parseIntOrDefault(request.getParameter("currentMaleCount"), 0);
        int currentFemaleCount = parseIntOrDefault(request.getParameter("currentFemaleCount"), 0);
        int currentThirdCount = parseIntOrDefault(request.getParameter("currentThirdCount"), 0);

        int isSharedRoom = "1".equals(request.getParameter("isSharedRoom")) ? 1 : 0;
        int hasAttachedWashroom = "1".equals(request.getParameter("hasAttachedWashroom")) ? 1 : 0;
        int utilityElectricity = "1".equals(request.getParameter("utilityElectricity")) ? 1 : 0;
        int utilityGas = "1".equals(request.getParameter("utilityGas")) ? 1 : 0;
        int utilityWater = "1".equals(request.getParameter("utilityWater")) ? 1 : 0;
        int utilityInternet = "1".equals(request.getParameter("utilityInternet")) ? 1 : 0;
        int utilityWaste = "1".equals(request.getParameter("utilityWaste")) ? 1 : 0;

        // -----------------------------------------------------------------
        // PHASE 3: ROOM IMAGE CLEANING RENAMING ENGINE
        // -----------------------------------------------------------------
        Part filePart = request.getPart("roomImage"); 
        String databasePhotoPath = ""; 
        String uniqueFileName = "";
        String activeTomcatFile = "";
        boolean codeHasImageToProcess = false;

        if (filePart != null && filePart.getSize() > 0) {
            String originalFileName = getSubmittedFileName(filePart);
            
            // Extract file extension securely
            String extension = ".png"; // standard fallback
            int extensionIndex = originalFileName.lastIndexOf('.');
            if (extensionIndex > 0) {
                extension = originalFileName.substring(extensionIndex);
            }
            
            // FIXED: Pure UUID creation pattern completely eliminates character spaces (%20)
            uniqueFileName = UUID.randomUUID().toString() + extension;
            
            String tomcatRunningPath = request.getServletContext().getRealPath("") 
                    + File.separator + "uploads" + File.separator + "listings";
            
            File tomcatDir = new File(tomcatRunningPath);
            if (!tomcatDir.exists()) {
                tomcatDir.mkdirs();
            }
            
            activeTomcatFile = tomcatRunningPath + File.separator + uniqueFileName;
            filePart.write(activeTomcatFile);
            
            // Only records filename string to prevent path traversal breakages
            databasePhotoPath = uniqueFileName;
            codeHasImageToProcess = true;
        }

        // -----------------------------------------------------------------
        // PHASE 4: TRANSACTIONAL DATABASE INSERT OPERATIONS
        // -----------------------------------------------------------------
        
        // FIXED: Added photo_path directly into primary query schema to resolve ORA-17006 mismatches
        String insertListingQuery = "INSERT INTO LISTINGS (poster_id, title, description, district, post_office, area, holding_number_lane, "
                                  + "preferred_religion, preferred_gender, preferred_smoking, num_rooms, available_rooms, is_shared_room, "
                                  + "has_attached_washroom, utility_electricity, utility_gas, utility_water, utility_internet, utility_waste, "
                                  + "current_roommates, current_male_count, current_female_count, current_third_count, rent, utility_charge_type, "
                                  + "utility_charge_amount, status, required_roommates, photo_path, publish_date) "
                                  + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'In review', ?, ?, SYSDATE)";

        String insertPhotoQuery = "INSERT INTO LISTING_PHOTOS (listing_id, photo_path) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); 

            long generatedListingId = -1;

            try (PreparedStatement ps = conn.prepareStatement(insertListingQuery, new String[]{"LISTING_ID"})) {
                ps.setInt(1, posterId);
                ps.setString(2, title);
                ps.setString(3, description);
                ps.setString(4, district);
                ps.setString(5, postOffice);
                ps.setString(6, area);
                ps.setString(7, holdingNumberLane);
                ps.setString(8, preferredReligion);
                ps.setString(9, preferredGender);
                ps.setString(10, preferredSmoking);
                ps.setInt(11, numRooms);
                ps.setInt(12, availableRooms);
                ps.setInt(13, isSharedRoom);
                ps.setInt(14, hasAttachedWashroom);
                ps.setInt(15, utilityElectricity);
                ps.setInt(16, utilityGas);
                ps.setInt(17, utilityWater);
                ps.setInt(18, utilityInternet);
                ps.setInt(19, utilityWaste);
                ps.setInt(20, currentRoommates);
                ps.setInt(21, currentMaleCount);
                ps.setInt(22, currentFemaleCount);
                ps.setInt(23, currentThirdCount);
                ps.setDouble(24, rent);
                ps.setString(25, utilityChargeType);
                ps.setDouble(26, utilityChargeAmount);
                ps.setInt(27, requiredRoommates);
                ps.setString(28, databasePhotoPath); // Persists clean unique string token record context directly
                
                ps.executeUpdate();

                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        generatedListingId = generatedKeys.getLong(1);
                    }
                }
            }

            // Workspace sync mirroring routine block
            if (generatedListingId != -1 && codeHasImageToProcess) {
                String baseRealPath = request.getServletContext().getRealPath("");
                String srcWorkspacePath = null;
                
                if (baseRealPath.contains(".metadata") && baseRealPath.contains("tmp")) {
                    int metadataIdx = baseRealPath.indexOf(File.separator + ".metadata");
                    String workspaceRoot = baseRealPath.substring(0, metadataIdx);
                    srcWorkspacePath = workspaceRoot + File.separator + "RoomLagbe.com" 
                                    + File.separator + "src" + File.separator + "main" 
                                    + File.separator + "webapp" + File.separator + "uploads" + File.separator + "listings";
                } else if (baseRealPath.contains("target")) {
                    int targetIdx = baseRealPath.indexOf(File.separator + "target");
                    String projectRoot = baseRealPath.substring(0, targetIdx);
                    srcWorkspacePath = projectRoot + File.separator + "src" + File.separator + "main" 
                                    + File.separator + "webapp" + File.separator + "uploads" + File.separator + "listings";
                }
                
                if (srcWorkspacePath != null) {
                    File workspaceDir = new File(srcWorkspacePath);
                    if (!workspaceDir.exists()) {
                        workspaceDir.mkdirs();
                    }
                    String activeWorkspaceFile = srcWorkspacePath + File.separator + uniqueFileName;
                    Files.copy(Paths.get(activeTomcatFile), Paths.get(activeWorkspaceFile), StandardCopyOption.REPLACE_EXISTING);
                }
                
                // Backup relational child data table synchronization entry path mapping
                try (PreparedStatement photoPs = conn.prepareStatement(insertPhotoQuery)) {
                    photoPs.setLong(1, generatedListingId);
                    photoPs.setString(2, IMAGE_PATH_PREFIX + uniqueFileName);
                    photoPs.executeUpdate();
                }
            }

            conn.commit(); 
            response.sendRedirect(request.getContextPath() + "/ListingServlet?action=listAll");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); 
                } catch (SQLException ex) {
                    log("Rollback failed statement", ex);
                }
            }
            throw new ServletException("Listing structural schema processing breakdown.", e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    log("Connection close failure context.", e);
                }
            }
        }
    }

    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf('/') + 1)
                               .substring(fileName.lastIndexOf('\\') + 1); 
            }
        }
        return "unknown_room.png";
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        try {
            return (value != null && !value.trim().isEmpty()) ? Integer.parseInt(value.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private double parseDoubleOrDefault(String value, double defaultValue) {
        try {
            return (value != null && !value.trim().isEmpty()) ? Double.parseDouble(value.trim()) : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}