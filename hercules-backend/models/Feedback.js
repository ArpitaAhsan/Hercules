const mongoose = require("mongoose");

const FeedbackSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
  },
  emergencyType: {
    type: String,
    required: true,
  },
  feedback: {
    type: String,
    required: true,
  },
}, { timestamps: true }); // adds createdAt and updatedAt automatically

module.exports = mongoose.model("Feedback", FeedbackSchema);
