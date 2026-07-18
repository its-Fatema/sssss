<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.roomlagbe.config.DBConnection, com.roomlagbe.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>RoomLagbe.com - Post Ad</title>
    <jsp:include page="_styles.jsp" />
    <style>
        .form-card-container { max-width: 700px; margin: 30px auto; background: #fff; padding: 25px; border: 1px solid #ddd; border-radius: 4px; box-shadow: 0 2px 5px rgba(0,0,0,0.04); }
        .form-section-title { font-size: 16px; font-weight: bold; color: #007bff; border-bottom: 1px solid #eee; padding-bottom: 5px; margin-top: 25px; margin-bottom: 15px; }
        .form-input-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 12px; }
        .input-block { display: flex; flex-direction: column; }
        .input-block label { font-weight: bold; font-size: 13px; margin-bottom: 4px; color: #444; }
        .input-field, .select-box, .textarea-field { padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; box-sizing: border-box; width: 100%; }
        .checkbox-row { display: flex; flex-wrap: wrap; gap: 15px; margin-top: 8px; }
        .checkbox-item { display: flex; align-items: center; gap: 5px; font-size: 13px; font-weight: bold; }
        .counter-btn { width: 30px; height: 30px; font-weight: bold; background: #eee; border: 1px solid #ccc; cursor: pointer; border-radius: 3px; }
    </style>
</head>
<body>
    <jsp:include page="_header.jsp" />

    <main class="container">
        <div class="form-card-container">
            <h2 style="margin-top:0; color:#222; text-align:center;">Create Room Advertisement</h2>
            <p style="text-align:center; color:#666; font-size:13px; margin-top:-5px; margin-bottom:20px;">Provide accurate descriptions and listing photos to find the right matching roommates.</p>

            <form action="ListingServlet?action=create" method="POST" enctype="multipart/form-data">
                
                <div class="input-block" style="margin-bottom:12px;">
                    <label>Advertisement Title</label>
                    <input type="text" name="title" class="input-field" required placeholder="Ex: Master Bedroom available for rent near AIUB">
                </div>

                <div class="input-block" style="margin-bottom:12px;">
                    <label>Detailed Description</label>
                    <textarea name="description" class="textarea-field" rows="4" required placeholder="Describe utilities, sub-let conditions, house rules, environment details..."></textarea>
                </div>

                <div class="form-section-title">Location Particulars</div>
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
                                        out.println("<option value='" + rs.getString("district") + "'>" + rs.getString("district") + "</option>");
                                    }
                                } catch (Exception e) { e.printStackTrace(); }
                            %>
                        </select>
                    </div>
                    <div class="input-block">
                        <label>Post Office</label>
                        <select name="post_office" id="postOfficeSelect" class="select-box" required onchange="loadAreas()">
                            <option value="">Select Post Office</option>
                        </select>
                    </div>
                </div>
                <div class="form-input-grid">
                    <div class="input-block">
                        <label>Area</label>
                        <select name="area" id="areaSelect" class="select-box" required>
                            <option value="">Select Area</option>
                        </select>
                    </div>
                    <div class="input-block">
                        <label>Holding Number & Lane Address</label>
                        <input type="text" name="holding_number_lane" class="input-field" required placeholder="Ex: House 43/A, Road 5, Block C">
                    </div>
                </div>

                <div class="form-section-title">Roommate Preferences</div>
                <div class="form-input-grid">
                    <div class="input-block">
                        <label>Preferred Religion</label>
                        <select name="preferred_religion" class="select-box" required>
                            <option value="Any">Any Religion</option>
                            <option value="Islam">Islam</option>
                            <option value="Hinduism">Hinduism</option>
                            <option value="Buddhism">Buddhism</option>
                            <option value="Christianity">Christianity</option>
                        </select>
                    </div>
                    <div class="input-block">
                        <label>Preferred Gender</label>
                        <select name="preferred_gender" class="select-box" required>
                            <option value="Any">Any Gender</option>
                            <option value="Male">Male Only</option>
                            <option value="Female">Female Only</option>
                        </select>
                    </div>
                </div>
                <div class="input-block">
                    <label>Smoking Preference</label>
                    <select name="preferred_smoking" class="select-box" required>
                        <option value="Non-smoker">Non-smoker preferred</option>
                        <option value="Allowed">Smoking Allowed</option>
                    </select>
                </div>

                <div class="form-section-title">Property Details & Composition Counter</div>
                <div class="form-input-grid">
                    <div class="input-block">
                        <label>Total Rooms in Flat</label>
                        <input type="number" name="num_rooms" class="input-field" required min="1" value="3">
                    </div>
                    <div class="input-block">
                        <label>Available Vacant Rooms</label>
                        <input type="number" name="available_rooms" class="input-field" required min="1" value="1">
                    </div>
                </div>

                <div class="checkbox-row">
                    <div class="checkbox-item"><input type="checkbox" name="is_shared_room" value="1"> Is Shared Room/Seat?</div>
                    <div class="checkbox-item"><input type="checkbox" name="has_attached_washroom" value="1"> Has Attached Washroom?</div>
                </div>

                <div class="form-input-grid" style="margin-top:15px;">
                    <div class="input-block">
                        <label>Current Roommates Total</label>
                        <input type="number" id="currentRoommates" name="current_roommates" class="input-field" required min="0" value="0" readonly>
                    </div>
                    <div class="input-block">
                        <label>Required New Roommates</label>
                        <input type="number" name="required_roommates" class="input-field" required min="1" value="1">
                    </div>
                </div>

                <%-- Dynamic Arithmetic +/- Click Counter Block Components --%>
                <div style="background:#f9f9f9; padding:12px; border-radius:4px; margin-bottom:12px;">
                    <label style="display:block; font-weight:bold; font-size:12px; color:#555; margin-bottom:8px;">Specify Current Occupant Composition Mix:</label>
                    <div style="display:flex; gap:20px; align-items:center;">
                        <div>
                            <span style="font-size:13px; color:#444; font-weight:bold; margin-right:5px;">Male:</span>
                            <button type="button" class="counter-btn" onclick="updateCompositionCounter('male', -1)">-</button>
                            <input type="text" id="maleCount" name="current_male_count" value="0" readonly style="width:25px; text-align:center; border:none; background:transparent; font-weight:bold;">
                            <button type="button" class="counter-btn" onclick="updateCompositionCounter('male', 1)">+</button>
                        </div>
                        <div>
                            <span style="font-size:13px; color:#444; font-weight:bold; margin-right:5px;">Female:</span>
                            <button type="button" class="counter-btn" onclick="updateCompositionCounter('female', -1)">-</button>
                            <input type="text" id="femaleCount" name="current_female_count" value="0" readonly style="width:25px; text-align:center; border:none; background:transparent; font-weight:bold;">
                            <button type="button" class="counter-btn" onclick="updateCompositionCounter('female', 1)">+</button>
                        </div>
                        <div>
                            <span style="font-size:13px; color:#444; font-weight:bold; margin-right:5px;">Third:</span>
                            <button type="button" class="counter-btn" onclick="updateCompositionCounter('third', -1)">-</button>
                            <input type="text" id="thirdCount" name="current_third_count" value="0" readonly style="width:25px; text-align:center; border:none; background:transparent; font-weight:bold;">
                            <button type="button" class="counter-btn" onclick="updateCompositionCounter('third', 1)">+</button>
                        </div>
                    </div>
                </div>

                <div class="form-section-title">Financial Details & Utilities Checklist</div>
                <div class="form-input-grid">
                    <div class="input-block">
                        <label>Monthly Rent Amount (BDT)</label>
                        <input type="number" name="rent" class="input-field" required min="1" placeholder="Ex: 6500">
                    </div>
                    <div class="input-block">
                        <label>Utility Charge Allocation</label>
                        <select name="utility_charge_type" id="utilType" class="select-box" required onchange="toggleUtilityPriceBox()">
                            <option value="Included">Included inside Rent</option>
                            <option value="Excluded">Excluded (Separate Bill)</option>
                        </select>
                    </div>
                </div>
                
                <div class="input-block" id="utilPriceBlock" style="margin-bottom:12px; display:none;">
                    <label>Utility Base Charge Cost Amount (BDT)</label>
                    <input type="number" name="utility_charge_amount" id="utilAmtField" class="input-field" placeholder="Ex: 800">
                </div>

                <label style="display:block; font-weight:bold; font-size:13px; color:#444; margin-bottom:5px;">Select Utilities Included inside Accommodation Flat:</label>
                <div class="checkbox-row" style="margin-bottom:15px; background:#f4f4f4; padding:10px; border-radius:4px;">
                    <div class="checkbox-item"><input type="checkbox" name="utility_electricity" value="1"> Electricity</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_gas" value="1"> Gas Connection</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_water" value="1"> Water Supply</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_internet" value="1"> Internet/Wi-Fi</div>
                    <div class="checkbox-item"><input type="checkbox" name="utility_waste" value="1"> Waste Management</div>
                </div>

                <div class="form-section-title">Property Gallery Binary Upload Pipeline</div>
                <div class="input-block" style="margin-bottom:25px;">
    <label>Upload Room Photos (Provide 1 to 5 Images)</label>
    
    <!-- Give them all the exact same name attribute so ListingServlet can loop through them dynamically -->
    <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 5px;">
        <input type="file" name="room_photos" class="input-field" accept="image/*" required>
        <input type="file" name="room_photos" class="input-field" accept="image/*">
        <input type="file" name="room_photos" class="input-field" accept="image/*">
        <input type="file" name="room_photos" class="input-field" accept="image/*">
        <input type="file" name="room_photos" class="input-field" accept="image/*">
    </div>
    <small style="color:#777; margin-top:4px;">The first image slot is required. The others are optional extensions.</small>
</div>

                <input type="submit" value="Publish Ad Room for Review" style="width:100%; padding:12px; background:#28a745; color:#fff; border:none; font-size:16px; font-weight:bold; border-radius:4px; cursor:pointer;">
            </form>
        </div>
    </main>

   <script>
        // Arithmetic increment operations processing composition mix counters dynamically
        function updateCompositionCounter(type, delta) {
            const field = document.getElementById(type + "Count");
            let val = parseInt(field.value) + delta;
            if (val < 0) val = 0;
            field.value = val;
            
            // Recompute total summation immediately
            const male = parseInt(document.getElementById("maleCount").value);
            const female = parseInt(document.getElementById("femaleCount").value);
            const third = parseInt(document.getElementById("thirdCount").value);
            document.getElementById("currentRoommates").value = male + female + third;
        }

        function toggleUtilityPriceBox() {
            const type = document.getElementById("utilType").value;
            const block = document.getElementById("utilPriceBlock");
            const field = document.getElementById("utilAmtField");
            if (type === "Excluded") {
                block.style.display = "block";
                field.required = true;
            } else {
                block.style.display = "none";
                field.required = false;
                field.value = "";
            }
        }

        // Cascading Dropdown Location Loader Hooks
        function loadPostOffices() {
            const dist = document.getElementById("districtSelect").value;
            const po = document.getElementById("postOfficeSelect");
            const area = document.getElementById("areaSelect");
            po.innerHTML = "<option value=''>Select Post Office</option>";
            area.innerHTML = "<option value=''>Select Area</option>";
            if (!dist) return;

            fetch("ListingServlet?action=getPostOffices&district=" + encodeURIComponent(dist))
                .then(res => res.json())
                .then(data => {
                    data.forEach(p => {
                        let o = document.createElement("option");
                        o.value = p; o.textContent = p; po.appendChild(o);
                    });
                });
        }

        function loadAreas() {
            const po = document.getElementById("postOfficeSelect").value;
            const area = document.getElementById("areaSelect");
            area.innerHTML = "<option value=''>Select Area</option>";
            if (!po) return;

            fetch("ListingServlet?action=getAreas&post_office=" + encodeURIComponent(po))
                .then(res => res.json())
                .then(data => {
                    data.forEach(a => {
                        let o = document.createElement("option");
                        o.value = a; o.textContent = a; area.appendChild(o);
                    });
                });
        }
    </script>
    <jsp:include page="_footer.jsp" />
</body>
</html>
    <jsp:include page="_footer.jsp" />
</body>
</html>