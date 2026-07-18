<%-- contact.jsp --%>
<%@ page pageEncoding="UTF-8" %>
<%@ include file="_header.jsp" %>

<!-- Centering layout structure -->
<div style="display: flex; flex-direction: column; min-height: 75vh; justify-content: center; align-items: center; width: 100%; padding: 40px 20px; box-sizing: border-box;">
    
    <!-- The Main Premium White Card Box -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-top: 6px solid #4f46e5; border-radius: 20px; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05); max-width: 600px; width: 100%; padding: 40px; box-sizing: border-box;">
        
        <h2 style="color: #0f172a; font-size: 1.75rem; font-weight: 800; margin: 0 0 10px 0; text-align: center; font-family: 'Inter', sans-serif;">
            Contact System Support Desk
        </h2>
        
        <p style="color: #64748b; font-size: 0.95rem; line-height: 1.5; margin: 0 0 30px 0; text-align: center; font-family: 'Inter', sans-serif;">
            Are you experiencing issues finding roommates or verifying your student mail profile account details?
        </p>
        
        <!-- Inside Grey Gray Info Display Box -->
        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 35px; box-sizing: border-box; font-family: 'Inter', sans-serif;">
            
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
                <span style="font-size: 1.25rem; line-height: 1;">✉️</span>
                <p style="margin: 0; color: #1e293b; font-size: 0.95rem;"><strong>Support Email:</strong> contact@roomlagbe.com</p>
            </div>
            
            <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
                <span style="font-size: 1.25rem; line-height: 1;">📞</span>
                <p style="margin: 0; color: #1e293b; font-size: 0.95rem;"><strong>Hotline Helpdesk:</strong> +880 1700-000000</p>
            </div>
            
            <div style="display: flex; align-items: flex-start; gap: 12px; margin: 0;">
                <span style="font-size: 1.25rem; line-height: 1;">📍</span>
                <p style="margin: 0; color: #1e293b; font-size: 0.95rem; line-height: 1.4;"><strong>HQ Address:</strong> RoomLagbe Tech Labs, Ruhitpur, Dhaka, Bangladesh</p>
            </div>
            
        </div>

        <!-- Row Grid for Buttons with full top isolation separation gap -->
        <div style="display: flex; gap: 16px; border-top: 1px solid #e2e8f0; padding-top: 24px; width: 100%; box-sizing: border-box;">
            
            <a href="${pageContext.request.contextPath}/index.jsp" 
               style="flex: 1; display: block; background: #f1f5f9; color: #0f172a; border: 1px solid #cbd5e1; text-align: center; padding: 12px 20px; font-weight: 600; font-size: 0.95rem; text-decoration: none; border-radius: 10px; box-sizing: border-box; transition: background 0.2s;">
               &larr; Back to Home
            </a>
            
            <a href="mailto:contact@roomlagbe.com?subject=RoomLagbe%20Support%20Inquiry" 
               style="flex: 1; display: block; background: #4f46e5; color: #ffffff; text-align: center; padding: 12px 20px; font-weight: 600; font-size: 0.95rem; text-decoration: none; border-radius: 10px; box-sizing: border-box; transition: background 0.2s;">
               Launch Mail App
            </a>
            
        </div>
    </div>
</div>

<%@ include file="_footer.jsp" %>