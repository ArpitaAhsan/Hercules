const express = require("express");
const bcrypt = require("bcryptjs");
const router = express.Router();
const User = require("../models/User"); 
const Alert = require("../models/Alert"); 
const Blog = require("../models/Blog"); //noor
const Feedback = require("../models/Feedback"); //sumiya



// ==================== SUMIYA START====================
// register User -sumiya
router.post("/register", async (req, res) => {
  try {
    let { name, email, password, phone, country } = req.body;

    // convert email to lowercase to avoid duplicate issues
    email = email.toLowerCase().trim();

    console.log("Registering email:", email); 

    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: "User already exists" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = new User({
      name,
      email,
      phone,
      country,
      password: hashedPassword,
      isEmergency: false,
      emergencyAlertColor: 'none',
      emergencyLocation: {
        type: 'Point',
        coordinates: [null, null],
      }
    });

    await user.save();
    res.json({ message: "User registered successfully" });
  } catch (err) {
    console.error("Error registering user:", err.message);
    res.status(500).send("Server Error");
  }
});

// login User -sumiya
router.post("/login", async (req, res) => {
  try {
    let { email, password } = req.body;

    // convert email to lowercase to avoid case mismatch issues
    email = email.toLowerCase().trim();

    console.log("Login request received with email:", email);

    let user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: "Invalid Credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Invalid Credentials" });
    }

    res.json({ message: "Login successful", userId: user._id });
  } catch (err) {
    console.error("Error during login:", err.message);
    res.status(500).send("Server Error");
  }
});


// ==================== FEEDBACK ====================
// Create Feedback
router.post("/feedback/create", async (req, res) => {
  try {
    const { email, emergencyType, feedback } = req.body;

    const newFeedback = new Feedback({
      email,
      emergencyType,
      feedback,
    });

    await newFeedback.save();
    res.status(201).json({ msg: "Feedback submitted", feedback: newFeedback });
  } catch (err) {
    console.error("Error creating feedback:", err.message);
    res.status(500).send("Server Error");
  }
});

// Get all Feedbacks
router.get("/feedback/all", async (req, res) => {
  try {
    const feedbacks = await Feedback.find().sort({ createdAt: -1 }); // newest first
    res.status(200).json(feedbacks);
  } catch (err) {
    console.error("Error fetching feedbacks:", err.message);
    res.status(500).send("Server Error");
  }
});


// ==================== SUMIYA END====================

//=============== NOOR STARTS ==========================

// update User Profile - noor
router.put("/profile/update/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, phone, country } = req.body;

    let user = await User.findById(userId);
    if (!user) return res.status(404).json({ msg: "User not found" });

    user.name = name || user.name;
    user.phone = phone || user.phone;
    user.country = country || user.country;

    await user.save();
    res.json({ message: "Profile updated successfully", user });
  } catch (err) {
    res.status(500).json({ msg: "Server error", error: err.message });
  }
});


// change User Password - noor
router.put("/changePassword/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const { currentPassword, newPassword } = req.body;

    // Fetch user from DB
    let user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    // Compare the current password with the hashed password in the database
    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect current password" });
    }

    // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update password
    user.password = hashedPassword;
    await user.save();

    res.json({ message: "Password updated successfully" });
  } catch (err) {
    console.error("Error changing password:", err.message);
    res.status(500).send("Server Error");
  }
});
// ====================BLOGS====================
// Create Blog Post
router.post("/create", async (req, res) => {
  try {
    const { email, helpType, priorityLevel, date, time, area } = req.body;

    const newPost = new Blog({
      email,
      helpType,
      priorityLevel,
      date,
      time,
      area,
    });

    await newPost.save();
    res.status(201).json({ msg: "Blog posted for help", blog: newPost });
  } catch (err) {
    console.error("Error creating blog:", err.message);
    res.status(500).send("Server Error");
  }
});


// Mark Blog as Done
router.put("/done/:blogId", async (req, res) => {
  try {
    const blog = await Blog.findById(req.params.blogId);
    if (!blog) return res.status(404).json({ msg: "Blog post not found" });

    blog.status = "Done";
    await blog.save();

    res.status(200).json({ msg: "Marked as done", blog });
  } catch (err) {
    console.error("Error finishing blog:", err.message);
    res.status(500).send("Server Error");
  }
});

// Get all active blogs
router.get("/active", async (req, res) => {
  try {
    const blogs = await Blog.find({ status: "Active" }).sort({ createdAt: -1 });
    res.status(200).json(blogs);
  } catch (err) {
    console.error("Error fetching blogs:", err.message);
    res.status(500).send("Server Error");
  }
});
// Respond to a Blog Post
router.post("/respond/:blogId/:email", async (req, res) => {
  try {
    const { blogId, email } = req.params;

    const blog = await Blog.findById(blogId);
    if (!blog) return res.status(404).json({ msg: "Blog post not found" });

    // Check if the user already responded
    if (blog.responders.includes(email)) {
      return res.status(400).json({ msg: "You have already responded to this blog." });
    }

    // Add user to responders array and increment the count
    blog.responders.push(email);
    blog.respondingCount += 1;

    await blog.save();

    res.status(200).json({ msg: "Responded successfully", blog });
  } catch (err) {
    console.error("Error responding to blog:", err.message);
    res.status(500).send("Server Error");
  }
});

router.get("/getUserIdByEmail/:email", async (req, res) => {
  try {
    const { email } = req.params;
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    res.status(200).json({ userId: user._id });
  } catch (err) {
    console.error("Error fetching userId by email:", err.message);
    res.status(500).send("Server Error");
  }
});
//=============== NOOR END==========================//=============== NOOR STARTS ==========================
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
