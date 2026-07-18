<%-- _styles.jsp --%>
<style type="text/css">
    /* ==========================================================================
       0. CORE DESIGN SYSTEM TOKENS & RESET
       ========================================================================== */
    :root {
        --primary: #4f46e5;
        --primary-light: #818cf8;
        --primary-dark: #3730a3;
        --accent: #0ea5e9;
        --success: #10b981;
        
        --bg-main: #f8fafc;
        --bg-surface: #ffffff;
        --bg-neutral: #f1f5f9;
        
        --text-heading: #0f172a;
        --text-body: #334155;
        --text-muted: #64748b;
        
        --border-light: #e2e8f0;
        --border-focus: #cbd5e1;
        
        /* Layered Soft Elevation Shadows */
        --shadow-sm: 0 1px 3px 0 rgba(15, 23, 42, 0.05);
        --shadow-md: 0 4px 6px -1px rgba(15, 23, 42, 0.05), 0 2px 4px -2px rgba(15, 23, 42, 0.05);
        --shadow-lg: 0 20px 25px -5px rgba(15, 23, 42, 0.08), 0 8px 10px -6px rgba(15, 23, 42, 0.08);
    }

    * { 
        box-sizing: border-box; 
        margin: 0; 
        padding: 0; 
    }

    body { 
        font-family: 'Inter', system-ui, -apple-system, sans-serif; 
        color: var(--text-body); 
        background-color: var(--bg-main); 
        line-height: 1.6; 
        -webkit-font-smoothing: antialiased;
    }
    
    /* Clean Base Layout Container Shell */
    .container { 
        max-width: 1340px; 
        margin: 0 auto; 
        padding: 2rem; 
    }


    /* ==========================================================================
       1. GLOBAL COMPONENTS & SHARED LAYOUT UI (_header.jsp, _footer.jsp, Buttons)
       ========================================================================== */
    /* Navigation Bar Module Header */
    .header-nav { 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        padding: 1.25rem 4rem; 
        background: var(--bg-surface); 
        box-shadow: var(--shadow-sm);
        border-bottom: 1px solid var(--border-light);
        position: sticky;
        top: 0;
        z-index: 1000; 
    }
    
    .header-nav .logo a { 
        display: flex;
        align-items: center;
        font-size: 1.65rem; 
        font-weight: 800; 
        color: var(--text-heading); 
        text-decoration: none; 
        letter-spacing: -0.04em;
    }
    
    .header-nav .logo a span {
        color: var(--primary);
    }
    
    .header-nav .logo img {
        height: 42px;
        width: auto;
        object-fit: contain;
        vertical-align: middle;
        transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .header-nav .logo img:hover {
        transform: scale(1.03);
    }
    
    .nav-links a { 
        margin-right: 2.25rem; 
        text-decoration: none; 
        color: var(--text-muted); 
        font-weight: 600; 
        font-size: 0.95rem;
        padding-bottom: 4px;
        border-bottom: 2px solid transparent;
        transition: all 0.2s ease;
    }
    
    .nav-links a:hover { 
        color: var(--primary); 
    }

    .header-nav .nav-links a.active {
        color: var(--primary) !important;
        border-bottom: 2px solid var(--primary) !important;
    }
    
    /* Circular Interactive Avatar Frame */
    .profile-trigger { 
        width: 42px; 
        height: 42px; 
        border-radius: 50%; 
        cursor: pointer; 
        border: 2px solid var(--border-light); 
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }
    
    .profile-trigger:hover {
        transform: scale(1.05);
        border-color: var(--primary-light);
        box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1);
    }

    /* Interactive Sidebar Drawer Layout */
    .sidebar-overlay { 
        position: fixed; 
        top: 0; 
        right: -360px; 
        width: 360px; 
        height: 100%; 
        background: var(--bg-surface); 
        box-shadow: var(--shadow-lg); 
        z-index: 2000; 
        transition: right 0.3s cubic-bezier(0.4, 0, 0.2, 1); 
        padding: 2.5rem 2rem; 
        display: flex; 
        flex-direction: column; 
    }
    
    .sidebar-overlay.open { 
        right: 0; 
    }
    
    .sidebar-close { 
        align-self: flex-end; 
        background: var(--bg-neutral); 
        border: none; 
        font-size: 1.2rem; 
        cursor: pointer; 
        width: 36px;
        height: 36px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--text-muted);
        transition: background-color 0.2s;
    }
    
    .sidebar-close:hover { background-color: #e2e8f0; }
    
    .profile-info { 
        text-align: center; 
        margin: 2rem 0; 
    }
    
    .profile-info img { 
        width: 84px; 
        height: 84px; 
        border-radius: 50%; 
        margin-bottom: 1rem; 
        border: 3px solid var(--primary-light);
    }
    
    .sidebar-links a { 
        display: block; 
        padding: 1rem 0.5rem; 
        text-decoration: none; 
        color: var(--text-heading); 
        font-weight: 600;
        border-bottom: 1px solid var(--border-light); 
        transition: padding 0.2s;
    }
    
    .sidebar-links a:hover {
        color: var(--primary);
        padding-left: 0.75rem;
    }

    /* Primary Action Buttons */
    .btn-view { 
        background: var(--primary); 
        color: #fff; 
        padding: 0.75rem 1.5rem; 
        text-decoration: none; 
        border-radius: 10px; 
        font-size: 0.95rem; 
        font-weight: 600; 
        text-align: center;
        transition: background-color 0.15s ease, transform 0.1s;
        border: none;
        display: inline-block;
    }
    
    .btn-view:hover { 
        background: var(--primary-dark); 
    }
    
    .btn-view:active { 
        transform: scale(0.98); 
    }

    /* Global Empty-State Canvas */
    .empty-state-card {
        background: var(--bg-surface);
        border: 2px dashed var(--border-focus);
        border-radius: 20px;
        padding: 4.5rem 2rem;
        text-align: center;
        box-shadow: var(--shadow-sm);
        width: 100%;
    }
    
    .empty-state-card p {
        color: var(--text-muted);
        font-size: 1.05rem;
        font-weight: 500;
    }

    /* Native Styled Display Ad Module Wrappers */
    .ad-placeholder { 
        background: linear-gradient(135deg, #f8fafc 25%, #f1f5f9 25%, #f1f5f9 50%, #f8fafc 50%, #f8fafc 75%, #f1f5f9 75%, #f1f5f9 100%);
        background-size: 40px 40px;
        border: 1px dashed var(--border-focus); 
        border-radius: 14px;
        text-align: center; 
        color: var(--text-muted); 
        font-size: 0.75rem; 
        display: flex; 
        align-items: center; 
        justify-content: center; 
        font-weight: 700; 
        text-transform: uppercase;
        letter-spacing: 0.1em;
        box-shadow: inset 0 2px 4px 0 rgba(0, 0, 0, 0.02);
    }
    
    .ad-header-banner { width: 100%; height: 90px; margin-bottom: 0.5rem; }
    .ad-sidebar-box { width: 100%; height: 280px; position: sticky; top: 6rem; }
    .ad-sidebar-drawer { width: 100%; height: 80px; margin-top: auto; }
    .ad-mid-feed { width: 100%; height: 100px; margin: 2rem 0; }


    /* ==========================================================================
       2. CSS FOR INDEX.JSP (MAIN PROPERTY EXPLORER HUB)
       ========================================================================== */
    /* Target Desktop Asymmetric Sidebar Column Allocation */
    @media(min-width: 992px) {
        .index-main-layout { 
            display: grid;
            grid-template-columns: 3.2fr 1.2fr;
            gap: 2rem;
        }
    }

    .filter-panel { 
        background: var(--bg-surface); 
        padding: 2.5rem; 
        border-radius: 20px; 
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-light); 
        position: relative;
        overflow: hidden;
        margin-bottom: 2rem;
    }
    
    .filter-panel::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, var(--primary), var(--accent));
    }
    
    .filter-panel h3 {
        font-size: 1.5rem;
        font-weight: 800;
        margin-bottom: 1.75rem;
        color: var(--text-heading);
        letter-spacing: -0.02em;
    }
    
    .filter-grid { 
        display: grid; 
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); 
        gap: 1.5rem; 
    }
    
    .filter-group label { 
        display: block; 
        font-size: 0.85rem; 
        margin-bottom: 0.5rem; 
        font-weight: 700; 
        color: var(--text-heading);
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    
    .filter-group select { 
        width: 100%; 
        padding: 0.85rem 1.25rem; 
        border: 1px solid var(--border-light); 
        border-radius: 10px; 
        background-color: var(--bg-neutral);
        color: var(--text-heading);
        font-weight: 600;
        font-size: 0.95rem;
        outline: none;
        appearance: none;
        background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
        background-repeat: no-repeat;
        background-position: right 1.25rem center;
        background-size: 0.9rem;
        cursor: pointer;
        transition: all 0.2s ease-in-out;
    }
    
    .filter-group select:focus {
        border-color: var(--primary-light);
        background-color: var(--bg-surface);
        box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1);
    }
    
    .filter-group select:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .listing-card { 
        background: var(--bg-surface); 
        border: 1px solid var(--border-light); 
        border-radius: 18px; 
        display: flex; 
        flex-direction: column; 
        overflow: hidden; 
        margin-bottom: 1.75rem; 
        box-shadow: var(--shadow-sm);
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .listing-card:hover {
        transform: translateY(-4px);
        box-shadow: var(--shadow-lg);
        border-color: var(--border-focus);
    }
    
    @media(min-width: 768px) {
        .listing-card { flex-direction: row; height: 220px; }
    }
    
    .card-left { 
        flex: 1; 
        background: #1e293b; 
        position: relative; 
        min-height: 180px; 
    }
    
    .image-slider { 
        width: 100%; 
        height: 100%; 
        display: flex; 
        overflow-x: auto; 
        scroll-snap-type: x mandatory; 
    }
    .image-slider::-webkit-scrollbar { display: none; }
    
    .image-slider img { 
        width: 100%; 
        height: 100%; 
        object-fit: cover; 
        flex-shrink: 0; 
        scroll-snap-align: start; 
    }
    
    .card-right { 
        flex: 1.4; 
        padding: 1.75rem; 
        display: flex; 
        flex-direction: column; 
        justify-content: space-between; 
    }
    
    .card-title { 
        font-size: 1.35rem; 
        font-weight: 700; 
        margin-bottom: 0.5rem; 
        color: var(--text-heading); 
        line-height: 1.3;
        letter-spacing: -0.01em;
    }
    
    .card-meta { 
        font-size: 0.9rem; 
        color: var(--text-muted); 
        margin-bottom: 0.3rem; 
        display: flex;
        align-items: center;
        gap: 0.4rem;
        font-weight: 500;
    }
    
    .card-footer { 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        border-top: 1px solid var(--border-light); 
        padding-top: 1rem; 
    }
    
    .card-price { 
        font-size: 1.5rem; 
        font-weight: 800; 
        color: var(--success); 
    }
    
    .card-price span { 
        font-size: 0.85rem; 
        font-weight: 500; 
        color: var(--text-muted); 
    }

    .pagination { 
        display: flex; 
        justify-content: center; 
        align-items: center; 
        gap: 0.5rem; 
        margin-top: 2.5rem; 
    }
    
    .pagination a { 
        padding: 0.75rem 1.25rem; 
        border: 1px solid var(--border-light); 
        background: var(--bg-surface); 
        text-decoration: none; 
        color: var(--text-heading); 
        border-radius: 10px; 
        font-weight: 600;
        font-size: 0.9rem;
        box-shadow: var(--shadow-sm);
        transition: all 0.2s;
    }
    
    .pagination a:hover { 
        border-color: var(--primary-light); 
        color: var(--primary); 
        transform: translateY(-1px);
    }
    
    .pagination .page-number {
        font-size: 0.9rem;
        font-weight: 700;
        color: var(--text-muted);
        padding: 0 1rem;
    }


    /* ==========================================================================
       3. CSS FOR VIEWLISTING.JSP (PROPERTY DETAIL RUNTIME SHEET)
       ========================================================================== */
    .detail-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 2.5rem;
        padding-top: 2rem;
    }

    @media(min-width: 992px) {
        .detail-grid {
            grid-template-columns: 1.8fr 1fr;
        }
    }

    .property-hero-frame {
        background: #1e293b;
        border-radius: 20px;
        height: 400px;
        overflow: hidden;
        box-shadow: var(--shadow-md);
        border: 1px solid var(--border-light);
    }

    .property-hero-frame img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .spec-header {
        margin: 1.5rem 0;
    }

    .spec-header h1 {
        font-size: 2rem;
        font-weight: 800;
        color: var(--text-heading);
        letter-spacing: -0.02em;
        line-height: 1.2;
    }

    .amenity-pill-box {
        display: flex;
        flex-wrap: wrap;
        gap: 0.75rem;
        margin: 1.5rem 0;
    }

    .amenity-pill {
        background-color: var(--bg-neutral);
        border: 1px solid var(--border-light);
        padding: 0.5rem 1rem;
        border-radius: 8px;
        font-size: 0.9rem;
        font-weight: 600;
        color: var(--text-body);
    }

    .sticky-action-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-light);
        border-radius: 20px;
        padding: 2.5rem;
        box-shadow: var(--shadow-lg);
        position: sticky;
        top: 6.5rem;
        height: fit-content;
    }

    .price-tag-large {
        font-size: 2.25rem;
        font-weight: 800;
        color: var(--success);
        margin-bottom: 0.25rem;
    }

    .price-tag-large span {
        font-size: 1rem;
        color: var(--text-muted);
        font-weight: 500;
    }

    .meta-table-list {
        margin: 2rem 0;
    }

    .meta-row-item {
        display: flex;
        justify-content: space-between;
        padding: 0.85rem 0;
        border-bottom: 1px solid var(--border-light);
        font-size: 0.95rem;
    }

    .meta-row-item:last-child {
        border-bottom: none;
    }

    .meta-row-item span:first-child {
        color: var(--text-muted);
        font-weight: 500;
    }

    .meta-row-item span:last-child {
        color: var(--text-heading);
        font-weight: 700;
    }

    .btn-apply-action {
        display: block;
        width: 100%;
        padding: 1rem;
        font-size: 1.05rem;
        font-weight: 700;
        text-align: center;
        border-radius: 12px;
        border: none;
        cursor: pointer;
        box-sizing: border-box;
        transition: all 0.2s;
    }  


    /* ==========================================================================
       4. CSS FOR APPLIED.JSP (STUDENT ENROLLMENT TRACKING MATRIX)
       ========================================================================== */
    .applied-container {
        padding: 1rem 0 3rem 0;
    }

    .page-title-area {
        margin-bottom: 2rem;
    }

    .page-title-area h2 {
        font-size: 1.75rem;
        font-weight: 800;
        color: var(--text-heading);
        letter-spacing: -0.02em;
    }

    .tracking-grid {
        display: flex;
        flex-direction: column;
        gap: 1.25rem;
    }

    .tracking-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-light);
        border-radius: 16px;
        padding: 1.5rem;
        display: grid;
        grid-template-columns: 1fr;
        gap: 1rem;
        align-items: center;
        box-shadow: var(--shadow-sm);
        transition: transform 0.2s, box-shadow 0.2s;
    }

    @media(min-width: 768px) {
        .tracking-card {
            grid-template-columns: 2fr 1.5fr 1fr 1fr;
            gap: 2rem;
        }
    }

    .tracking-card:hover {
        transform: translateY(-2px);
        box-shadow: var(--shadow-md);
    }

    .room-info-meta h4 {
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--text-heading);
        margin-bottom: 0.25rem;
    }

    .room-info-meta p {
        font-size: 0.85rem;
        color: var(--text-muted);
    }

    .poster-contact-box {
        font-size: 0.9rem;
        color: var(--text-body);
    }

    .poster-contact-box strong {
        display: block;
        color: var(--text-heading);
        font-size: 0.95rem;
    }

    .status-pill {
        display: inline-block;
        padding: 0.5rem 1rem;
        border-radius: 30px;
        font-size: 0.85rem;
        font-weight: 700;
        text-align: center;
        width: fit-content;
    }

    .status-pending {
        background-color: #fef3c7;
        color: #d97706;
        border: 1px solid #fde68a;
    }

    .status-accepted {
        background-color: #dcfce7;
        color: #15803d;
        border: 1px solid #bbf7d0;
    }

    .status-rejected {
        background-color: #fee2e2;
        color: #b91c1c;
        border: 1px solid #fecaca;
    }


    /* ==========================================================================
       5. CSS FOR MYLISTINGS.JSP (POSTER MANAGEMENT DASHBOARD)
       ========================================================================== */
    .badge {
        display: inline-flex;
        align-items: center;
        padding: 0.35rem 0.75rem;
        border-radius: 9999px;
        font-size: 0.8rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .badge-review { background-color: #fef3c7; color: #d97706; }
    .badge-running { background-color: #dcfce7; color: #15803d; }
    .badge-closed { background-color: #f1f5f9; color: #475569; }

    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2rem;
        background: var(--bg-surface);
        padding: 1.5rem 2rem;
        border-radius: 16px;
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border-light);
    }

    .applicant-section {
        background-color: var(--bg-neutral);
        border-radius: 12px;
        margin-top: 1rem;
        padding: 1.5rem;
        display: none; /* Controlled dynamically via your JavaScript layer */
        border: 1px solid var(--border-light);
    }

    .applicant-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 1rem;
        margin-top: 1rem;
    }

    .applicant-card {
        background: var(--bg-surface);
        border: 1px solid var(--border-light);
        border-radius: 12px;
        padding: 1.25rem;
        box-shadow: var(--shadow-sm);
    }

    .applicant-meta {
        font-size: 0.85rem;
        color: var(--text-muted);
        margin-bottom: 0.75rem;
    }

    .action-group {
        display: flex;
        gap: 0.5rem;
        margin-top: 1rem;
    }

    .btn-action {
        flex: 1;
        padding: 0.5rem;
        font-size: 0.85rem;
        font-weight: 700;
        border-radius: 6px;
        border: none;
        cursor: pointer;
        text-align: center;
        text-decoration: none;
        transition: background-color 0.15s;
    }

    .btn-accept { background-color: var(--success); color: white; }
    .btn-accept:hover { background-color: #059669; }
    .btn-reject { background-color: #ef4444; color: white; }
    .btn-reject:hover { background-color: #dc2626; }
    .btn-whatsapp { background-color: #25d366; color: white; }
    .btn-whatsapp:hover { background-color: #22c55e; }


    /* ==========================================================================
       6. CSS FOR CONTACT.JSP (SUPPORT DATA MODULE PANEL)
       ========================================================================== */
    .contact-page-layout {
        display: flex;
        flex-direction: column;
        min-height: 80vh; 
        justify-content: center;
        align-items: center;
        width: 100%;
        box-sizing: border-box;
        padding: 3rem 1rem;
    }

    .contact-card-premium {
        background: var(--bg-surface);
        border-radius: 20px; 
        box-shadow: var(--shadow-lg);
        border: 1px solid var(--border-light); 
        position: relative;
        overflow: hidden;
        max-width: 640px;
        width: 100%;
        padding: 3rem; 
        box-sizing: border-box;
    }

    .contact-card-premium::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 6px;
        background: linear-gradient(90deg, var(--primary), var(--accent));
    }

    .contact-card-premium h2 {
        color: var(--text-heading);
        font-weight: 800;
        font-size: 1.8rem;
        margin-bottom: 0.75rem;
        letter-spacing: -0.02em;
        text-align: center; 
    }

    .contact-card-premium .subtitle {
        color: var(--text-muted);
        font-size: 1rem;
        margin-bottom: 2rem;
        text-align: center; 
        line-height: 1.5;
    }

    .info-display-panel {
        background: var(--bg-neutral);
        border-radius: 12px;
        padding: 1.75rem;
        margin-bottom: 2.5rem; 
        border: 1px solid var(--border-light);
        box-sizing: border-box;
    }

    .info-row {
        margin-bottom: 1.25rem;
        display: flex;
        align-items: flex-start; 
        gap: 1rem;
    }

    .info-row:last-child {
        margin-bottom: 0;
    }

    .info-row span {
        font-size: 1.3rem;
        line-height: 1;
        margin-top: 2px;
    }

    .info-row p {
        font-size: 0.95rem;
        color: var(--text-heading);
        margin: 0;
        line-height: 1.4;
        text-align: left; 
    }

    .contact-actions {
        display: flex;
        gap: 1rem;
        justify-content: center;
        align-items: center;
        border-top: 1px solid var(--border-light);
        padding-top: 2rem;
        margin-top: 1rem;
        width: 100%;
    }

    .contact-actions .btn-view {
        display: block !important;
        flex: 1 !important;
        padding: 0.85rem 1.25rem !important; 
        font-size: 0.95rem !important;
        font-weight: 600 !important;
        text-align: center !important;
        border-radius: 10px !important;
        text-decoration: none !important;
        box-sizing: border-box !important;
    }

    .contact-actions .btn-secondary-nav {
        background-color: var(--bg-neutral) !important;
        color: var(--text-heading) !important;
        border: 1px solid var(--border-light) !important;
    }

    .contact-actions .btn-secondary-nav:hover {
        background-color: #e2e8f0 !important;
    }
</style>