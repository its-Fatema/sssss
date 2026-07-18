package com.roomlagbe.filter;

import com.roomlagbe.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

// Intercepts administrative templates and endpoints to prevent unauthorized access
@WebFilter(urlPatterns = {"/admin.jsp", "/ListingServlet?action=approve", "/ListingServlet?action=reject"})
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization logic if required when container spins up
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false); // Fetch session if it exists natively

        boolean authorized = false;

        if (session != null) {
            User currentUser = (User) session.getAttribute("currentUser");
            
            // Check if the user is authenticated and possesses the strict 'admin' privilege profile
            if (currentUser != null && "admin".equalsIgnoreCase(currentUser.getRole())) {
                authorized = true;
            }
        }

        if (authorized) {
            // User is a valid admin. Let the request pass through cleanly down the line
            chain.doFilter(request, response);
        } else {
            // Access violation! Deny context propagation and kick them back to the home feed
            httpRequest.setAttribute("error", "Access denied. Administrative authentication privileges required.");
            httpRequest.getRequestDispatcher("index.jsp").forward(request, httpResponse);
        }
    }

    @Override
    public void destroy() {
        // Cleanup resources context layers if required by container limits
    }
}