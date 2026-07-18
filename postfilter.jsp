<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Intercept data filter items submitted via separate modal panels
    String district = request.getParameter("district");
    String postOffice = request.getParameter("post_office");
    String area = request.getParameter("area");
    String gender = request.getParameter("preferred_gender");
    String minRent = request.getParameter("min_rent");
    String maxRent = request.getParameter("max_rent");

    // Construct a sanitized URL query string to pass to the main homepage feed
    StringBuilder targetUrl = new StringBuilder("index.jsp?page=1");
    
    if (district != null && !district.isEmpty()) targetUrl.append("&district=").append(java.net.URLEncoder.encode(district, "UTF-8"));
    if (postOffice != null && !postOffice.isEmpty()) targetUrl.append("&post_office=").append(java.net.URLEncoder.encode(postOffice, "UTF-8"));
    if (area != null && !area.isEmpty()) targetUrl.append("&area=").append(java.net.URLEncoder.encode(area, "UTF-8"));
    if (gender != null && !gender.isEmpty()) targetUrl.append("&preferred_gender=").append(java.net.URLEncoder.encode(gender, "UTF-8"));
    if (minRent != null && !minRent.isEmpty()) targetUrl.append("&min_rent=").append(minRent);
    if (maxRent != null && !maxRent.isEmpty()) targetUrl.append("&max_rent=").append(maxRent);

    // Fast seamless server redirect response execution[cite: 1]
    response.sendRedirect(targetUrl.toString());
%>