package com.roomlagbe.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Listing {
    private int listingId;
    private int posterId;
    private String title;
    private String description;
    private String district;
    private String postOffice;
    private String area;
    private String holdingNumberLane;
    private String preferredReligion;
    private String preferredGender;
    private String preferredSmoking;
    private int numRooms;
    private int availableRooms;
    private int isSharedRoom;
    private int hasAttachedWashroom;
    private int utilityElectricity;
    private int utilityGas;
    private int utilityWater;
    private int utilityInternet;
    private int utilityWaste;
    private int currentRoommates;
    private int currentMaleCount;
    private int currentFemaleCount;
    private int currentThirdCount;
    private double rent;
    private String utilityChargeType;
    private Double utilityChargeAmount; // Nullable if included
    private String status;
    private int requiredRoommates;
    private Date publishDate;
    
    // Dynamic array handling 1 to 5 multiple photo uploads per ad listing
    private List<String> photoPaths = new ArrayList<>();

    public Listing() {}

    // Getters and Setters
    public int getListingId() { return listingId; }
    public void setListingId(int listingId) { this.listingId = listingId; }

    public int getPosterId() { return posterId; }
    public void setPosterId(int posterId) { this.posterId = posterId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getPostOffice() { return postOffice; }
    public void setPostOffice(String postOffice) { this.postOffice = postOffice; }

    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }

    public String getHoldingNumberLane() { return holdingNumberLane; }
    public void setHoldingNumberLane(String holdingNumberLane) { this.holdingNumberLane = holdingNumberLane; }

    public String getPreferredReligion() { return preferredReligion; }
    public void setPreferredReligion(String preferredReligion) { this.preferredReligion = preferredReligion; }

    public String getPreferredGender() { return preferredGender; }
    public void setPreferredGender(String preferredGender) { this.preferredGender = preferredGender; }

    public String getPreferredSmoking() { return preferredSmoking; }
    public void setPreferredSmoking(String preferredSmoking) { this.preferredSmoking = preferredSmoking; }

    public int getNumRooms() { return numRooms; }
    public void setNumRooms(int numRooms) { this.numRooms = numRooms; }

    public int getAvailableRooms() { return availableRooms; }
    public void setAvailableRooms(int availableRooms) { this.availableRooms = availableRooms; }

    public int getIsSharedRoom() { return isSharedRoom; }
    public void setIsSharedRoom(int isSharedRoom) { this.isSharedRoom = isSharedRoom; }

    public int getHasAttachedWashroom() { return hasAttachedWashroom; }
    public void setHasAttachedWashroom(int hasAttachedWashroom) { this.hasAttachedWashroom = hasAttachedWashroom; }

    public int getUtilityElectricity() { return utilityElectricity; }
    public void setUtilityElectricity(int utilityElectricity) { this.utilityElectricity = utilityElectricity; }

    public int getUtilityGas() { return utilityGas; }
    public void setUtilityGas(int utilityGas) { this.utilityGas = utilityGas; }

    public int getUtilityWater() { return utilityWater; }
    public void setUtilityWater(int utilityWater) { this.utilityWater = utilityWater; }

    public int getUtilityInternet() { return utilityInternet; }
    public void setUtilityInternet(int utilityInternet) { this.utilityInternet = utilityInternet; }

    public int getUtilityWaste() { return utilityWaste; }
    public void setUtilityWaste(int utilityWaste) { this.utilityWaste = utilityWaste; }

    public int getCurrentRoommates() { return currentRoommates; }
    public void setCurrentRoommates(int currentRoommates) { this.currentRoommates = currentRoommates; }

    public int getCurrentMaleCount() { return currentMaleCount; }
    public void setCurrentMaleCount(int currentMaleCount) { this.currentMaleCount = currentMaleCount; }

    public int getCurrentFemaleCount() { return currentFemaleCount; }
    public void setCurrentFemaleCount(int currentFemaleCount) { this.currentFemaleCount = currentFemaleCount; }

    public int getCurrentThirdCount() { return currentThirdCount; }
    public void setCurrentThirdCount(int currentThirdCount) { this.currentThirdCount = currentThirdCount; }

    public double getRent() { return rent; }
    public void setRent(double rent) { this.rent = rent; }

    public String getUtilityChargeType() { return utilityChargeType; }
    public void setUtilityChargeType(String utilityChargeType) { this.utilityChargeType = utilityChargeType; }

    public Double getUtilityChargeAmount() { return utilityChargeAmount; }
    public void setUtilityChargeAmount(Double utilityChargeAmount) { this.utilityChargeAmount = utilityChargeAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getRequiredRoommates() { return requiredRoommates; }
    public void setRequiredRoommates(int requiredRoommates) { this.requiredRoommates = requiredRoommates; }

    public Date getPublishDate() { return publishDate; }
    public void setPublishDate(Date publishDate) { this.publishDate = publishDate; }

    public List<String> getPhotoPaths() { return photoPaths; }
    public void setPhotoPaths(List<String> photoPaths) { this.photoPaths = photoPaths; }
}