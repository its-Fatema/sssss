package com.roomlagbe.model;

import java.util.Date;

public class Application {
    private int applicationId;
    private int listingId;
    private int applicantId;
    private int posterAccepted;
    private int applicantAccepted;
    private String status;
    private Date appliedDate;

    public Application() {}

    // Getters and Setters
    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }

    public int getListingId() { return listingId; }
    public void setListingId(int listingId) { this.listingId = listingId; }

    public int getApplicantId() { return applicantId; }
    public void setApplicantId(int applicantId) { this.applicantId = applicantId; }

    public int getPosterAccepted() { return posterAccepted; }
    public void setPosterAccepted(int posterAccepted) { this.posterAccepted = posterAccepted; }

    public int getApplicantAccepted() { return applicantAccepted; }
    public void setApplicantAccepted(int applicantAccepted) { this.applicantAccepted = applicantAccepted; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getAppliedDate() { return appliedDate; }
    public void setAppliedDate(Date appliedDate) { this.appliedDate = appliedDate; }
}