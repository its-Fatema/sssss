package com.roomlagbe.model;

import java.util.Date;

public class User {
    private int userId;
    private String fullName;
    private String email;
    private String passwordHash;
    private String gender;
    private Date birthdate;
    private String religion;
    private String contactNumber;
    private String photoPath;
    private String role;
    private int isVerified;
    private int isBlocked;

    // Default Constructor
    public User() {}

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public Date getBirthdate() { return birthdate; }
    public void setBirthdate(Date birthdate) { this.birthdate = birthdate; }

    public String getReligion() { return religion; }
    public void setReligion(String religion) { this.religion = religion; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getIsVerified() { return isVerified; }
    public void setIsVerified(int isVerified) { this.isVerified = isVerified; }

    public int getIsBlocked() { return isBlocked; }
    public void setIsBlocked(int isBlocked) { this.isBlocked = isBlocked; }
}