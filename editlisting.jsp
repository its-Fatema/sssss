<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.roomlagbe.config.DBConnection, com.roomlagbe.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String idParam = request.getParameter("id");
    if (currentUser == null || idParam == null || idParam.isEmpty()) {
        response.sendRedirect("mylistings.jsp");
        return;
    }
    int targetId = Integer.parseInt(idParam);
    int currentUserId = currentUser.getUserId();

    // Data values retention variables
    String title = "", description = "", district = "", postOffice = "", area = "", holding = "";
    String religion = "", gender = "", smoking = "", utilType = "", status = "";
    int numRooms = 0, availRooms = 0, isShared = 0, hasWashroom = 0, reqRoommates = 0;
    int elec = 0, gas = 0, water = 0, internet = 0, waste = 0;
    int roommates = 0, mCount = 0, fCount = 0, tCount = 0;
    double rent = 0.0;
    Double utilAmt = null;

    String sql = "SELECT * FROM LISTINGS WHERE listing_id = ? AND poster_id = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, targetId);
        stmt.setInt(2, currentUserId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                title = rs.getString("title");
                description = rs.getString("description");
                district = rs.getString("district");
                postOffice = rs.getString("post_office");
                area = rs.getString("area");
                holding = rs.getString("holding_number_lane");
                religion = rs.getString("preferred_religion");
                gender = rs.getString("preferred_gender");
                smoking = rs.getString("preferred_smoking");
                numRooms = rs.getInt("num_rooms");
                availRooms = rs.getInt("available_rooms");
                isShared = rs.getInt("is_shared_room");
                hasWashroom = rs.getInt("has_attached_washroom");
                elec = rs.getInt("utility_electricity");
                gas = rs.getInt("utility_gas");
                water = rs.getInt("utility_water");
                internet = rs.getInt("utility_internet");
                waste = rs.getInt("utility_waste");
                roommates = rs.getInt("current_roommates");
                mCount = rs.getInt("current_male_count");
                fCount = rs.getInt("current_female_count");
                tCount = rs.getInt("current_third_count");
                rent = rs.getDouble("rent");
                utilType = rs.getString("utility_charge_type");
                
                double amt = rs.getDouble("utility_charge_amount");
                if (!rs.wasNull()) utilAmt = amt;
                
                status = rs.getString("status");
                reqRoommates = rs.getInt("required_roommates");
            } else {
                response.sendRedirect("mylistings.jsp");
                return;
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Edit Ad</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .form-card-container { max-width: 700px; margin: 30px auto; background: #fff; padding: 25px; border: 1px solid #ddd; border-radius: 4px; }
        .form-section-title { font-size: 15px; font-weight: bold; color: #007bff; border-bottom: 1px solid #eee; padding-bottom: 4px; margin-top: 20px; margin-bottom: 15px; }
        .form-input-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 12px; }
        .input-block { display: flex; flex-direction: column; }
        .input-block label { font-weight: bold; font-size: 13px; margin-bottom: 4px; }
        .input-field, .select-box, .textarea-field { padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .checkbox-row { display: flex; flex-wrap: wrap; gap: 15px; margin-top: 8px; }
        .checkbox-item { display: flex; align-items: center; gap: 5px; font-size: 13px; }
        .counter-btn { width: 30px; height: 30px; font-weight: bold; background: #eee; border: 1px solid #ccc; cursor: pointer; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container">
        <div class="form-card-container">
            <h2 style="margin-top:0; text-align:center;">Modify Room Specification Details</h2>
            
            <!-- Send details back into unified servlet action pipeline layers[cite: 1] -->
            <form action="ListingServlet?action=update" method="POST">
                <input type="hidden" name="listing_id" value="<%= targetId %>">
                
                <div class="input-block" style="margin-bottom:12px;">
                    <label>Ad Title</label>
                    <input type="text" name="title" class="input-field" required value="<%= title %>">
                </div>

                <div class="input-block" style="margin-bottom:12px;">
                    <label>Description Details</label>
                    <textarea name="description" class="textarea-field" rows="4" required><%= description %></textarea>
                </div>

                <div class="form-section-title">Current Address Details</div>
                <div style="background:#f4f4f4; padding:8px; border-radius:4px; font-size:13px; margin-bottom:10px; color:#555;">
                    Current Saved Address: <strong><%= holding %>, <%= area %>, <%= postOffice %>, <%= district %></strong>
                </div>
                <p style="font-size:11px; color:#777; margin:0 0 10px 0;">To update the location context, use the dropdown menus below to re-fetch the area parameters:</p>
                
                <div class="form-input-grid">
                    <div class="input-block">
                        <label>District</label>
                        <select name="district" id="districtSelect" class="select-box" required onchange="loadPostOffices()">
                            <option value="">Select District</option>
                            <%
                                try (Connection conn = DBConnection.getConnection();
                                     Statement stmt = conn.createStatement();
                                     ResultSet rs = stmt.executeQuery("SELECT DISTINCT district FROM LOCATIONS ORDER BY district")) {
                                    while (rs.next()) {
                                        String d = rs.getString("district");
                                        String sel = d.equals(district) ? "selected" : "";
                                        out.println("<option value='" + d + "' " + sel + ">" + d + "</option>");
                                    }
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>
                    <div class="input-block">
                        <label>Post Office</label>
                        <select name="post_office" id="postOfficeSelect" class="select-box" required onchange="loadAreas()">
                            <option value="<%= postOffice %>" selected><%= postOffice %></option>
                        </select>
                    </div>
                </div>
                <div class="form-input-grid">
                    <div class="input-block">
                        <label>Area</label>
                        <select name="area" id="areaSelect" class="select-box" required>
                            <option value="<%= area %>" selected><%= area %></option>
                        </select>
                    </div>
                    <div class="input-block">
                        <label>Holding Number & Lane</label>
                        <input type="text" name="holding_number_lane" class="input-field" required value="<%= holding %>">
                    </div>
                </div>

                <div class="form-section-title">Target Parameters & Filters</div>
                <div class="form-input-grid">
                    <div class="input-block">
                        <label>Preferred Religion</label>
                        <select name="preferred_religion" class="select-box" required>
                            <option value="Any" <%= "Any".equals(religion)?"selected":"" %>>Any Religion</option>
                            <option value="Islam" <%= "Islam".equals(religion)?"selected":"" %>>Islam</option>
                            <option value="Hinduism" <%= "Hinduism".equals(religion)?"selected":"" %>>Hinduism</option>
                            <option value="Buddhism" <%= "Buddhism".equals(religion)?"selected":"" %>>Buddhism</option>
                            <option value="Christianity" <%= "Christianity".equals(religion)?"selected":"" %>>Christianity</option>
                        </select>
                    </div>
                    <div class="input-block">
                        <label>Preferred Gender</label>
                        <select name="preferred_gender" class="select-box" required>
                            <option value="Any" <%= "Any".equals(gender)?"selected":"" %>>Any Gender</option>
                            <option value="Male" <%= "Male".equals(gender)?"selected":"" %>>Male Only</option>
                            <option value="Female" <%= "Female".equals(gender)?"selected":"" %>>Female Only</option>
                        </select>
                    </div>
                </div>

                <div class="form-input-grid">
                    <div class="input-block">
                        <label>Monthly Rent (BDT)</label>
                        <input type="number" name="rent" class="input-field" required value="<%= (int)rent %>">
                    </div>
                    <div class="input-block">
                        <label>Listing Display Status</label>
                        <select name="status" class="select-box" required>
                            <option value="In review" <%= "In review".equals(status)?"selected":"" %>>In review</option>
                            <option value="Ad running" <%= "Ad running".equals(status)?"selected":"" %>>Ad running</option>
                            <option value="Closed" <%= "Closed".equals(status)?"selected":"" %>>Closed</option>
                        </select>
                    </div>
                </div>

                <div class="checkbox-row" style="margin-top:15px; margin-bottom:15px;">
                    <div class="checkbox-item"><input type="checkbox" name="is_shared_room" value="1" <%= (isShared==1)?"checked":"" %>> Shared Room Space</div>
                    <div class="checkbox-item"><input type="checkbox" name="has_attached_washroom" value="1" <%= (hasWashroom==1)?"checked":"" %>> Attached Washroom</div>
                </div>

                <div class="checkbox-row" style="background:#f4f4f4; padding:10px; border-radius:4px; margin-bottom:20px;">
                    <div class="checkbox-item"><input type="checkbox" name="utility_electricity" value="1" <%= (elec==1)?"checked":"" %>> Electricity</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_gas" value="1" <%= (gas==1)?"checked":"" %>> Gas</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_water" value="1" <%= (water==1)?"checked":"" %>> Water</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_internet" value="1" <%= (internet==1)?"checked":"" %>> Internet</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_waste" value="1" <%= (waste==1)?"checked":"" %>> Waste Disposal</div>
                </div>

                <input type="submit" value="Save Property Changes" style="width:100%; padding:12px; background:#007bff; color:#fff; border:none; font-size:16px; font-weight:bold; cursor:pointer; border-radius:4px;">
            </form>
        </div>
    </main>
    
    <script>
        // Copy the loadPostOffices and loadAreas AJAX scripts straight from addlisting.jsp down here
    </script>
    <jsp:include page="_footer.jsp" />
</body>
</html>