const express = require("express");
const bcrypt = require("bcryptjs");
const router = express.Router();
const User = require("../models/User"); 
const Alert = require("../models/Alert"); 

// ==================== ARPITA START====================
// update User Emergency Status --arpita
router.put("/updateEmergencyStatus/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const { isEmergency, emergencyAlertColor, emergencyLocation } = req.body;

    // Find the user by their ID
    let user = await User.findById(userId);
    if (!user) {
      return res.status(400).json({ msg: "User not found" });
    }

    // Update the user's emergency status
    user.isEmergency = isEmergency;
    user.emergencyAlertColor = emergencyAlertColor;
    user.emergencyLocation = emergencyLocation;

    await user.save();
    res.json({ message: "Emergency status updated successfully", user });
  } catch (err) {
    console.error("Error updating emergency status:", err.message);
    res.status(500).send("Server Error");
  }
});


///// nicher part ta nwew addd korsi

// get User Profile -- arpita
router.get("/profile/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    console.log("Received userId:", userId);

    // Fetch user from DB
    let user = await User.findById(userId).select("-password");
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    res.json({
      name: user.name,
      email: user.email,
      phone: user.phone,
      country: user.country,
      isEmergency: user.isEmergency,
      emergencyAlertColor: user.emergencyAlertColor,
      emergencyLocation: user.emergencyLocation,
    });
  } catch (err) {
    console.error("Error fetching user profile:", err.message);
    res.status(500).send("Server Error");
  } 
});

// ==================== TRIGGER EMERGENCY ====================
router.post("/trigger-emergency/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ msg: "User not found" });

    user.isEmergency = true;
    user.emergencyAlertColor = "red";

    await user.save();

    res.status(200).json({ msg: "Emergency triggered", user });
  } catch (err) {
    console.error("❌ Error triggering emergency:", err);
    res.status(500).json({ msg: "Server error" });
  }
});

// ==================== FINISH ALERT ====================
router.put("/alert/finish/:alertId", async (req, res) => {
  try {
    const alert = await Alert.findById(req.params.alertId);
    if (!alert) return res.status(404).json({ msg: "Alert not found" });

    alert.isEmergency = false;
    alert.finishedAt = new Date(); // Set finishedAt to the current date/time
    alert.alertColor = "grey"; // Change the alert color or do any other UI-related updates

    await alert.save();

    await User.findByIdAndUpdate(alert.userId, {
      isEmergency: false,
      emergencyAlertColor: "none",
    });

    res.json({ msg: "Emergency marked as finished", alert });
  } catch (err) {
    console.error("Error finishing emergency:", err.message);
    res.status(500).send("Server Error");
  }
});


// ==================== LOG ALERT ====================
router.post("/log-alert/:userId", async (req, res) => {
  const { userId } = req.params;
  const { emergencyType, alertColor,location } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ msg: "User not found" });

    // Check if there's any unfinished alert for this user
    await Alert.updateMany(
      { userId, finishedAt: null },
      {
        $set: {
          finishedAt: new Date(),
          isEmergency: false,
          alertColor: "grey",
        },
      }
    );

    const newAlert = new Alert({
      userId,
      emergencyType,
      alertColor,
      isEmergency: true,
      location,
    });

    await newAlert.save();

    user.isEmergency = true;
    user.emergencyAlertColor = alertColor;
    user.emergencyLocation = location;
    await user.save();

    res.status(201).json({
      msg: "Alert logged successfully",
      alert: newAlert,
      userUpdated: true,
    });
  } catch (err) {
    console.error("Error logging alert:", err.message);
    res.status(500).send("Server Error");
  }
});

// ==================== GET ALERTS BY USER ====================
router.get("/alerts/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    const alerts = await Alert.find({ userId }).sort({ createdAt: -1 }); // newest first
    res.status(200).json(alerts);
  } catch (err) {
    console.error("Error fetching alerts:", err.message);
    res.status(500).json({ msg: "Server Error" });
  }
});



// ==================== GET ACTIVE ALERTS ====================
router.get("/active-alerts", async (req, res) => {
  try {
    // whats my query for active alerts (isEmergency: true and finishedAt: null)
    const activeAlerts = await Alert.find({ 
      isEmergency: true, 
      finishedAt: null 
    }).sort({ createdAt: -1 }); // gotta sort by most recent alert

    if (activeAlerts.length === 0) {
      return res.status(404).json({ msg: "No active alerts found" });
    }

    // returning the active alerts
    res.status(200).json(activeAlerts);
  } catch (err) {
    console.error("Error fetching active alerts:", err.message);
    res.status(500).json({ msg: "Server Error" });
  }
});


module.exports = router;
