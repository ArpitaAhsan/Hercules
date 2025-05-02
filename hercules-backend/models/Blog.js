const mongoose = require("mongoose");

const BlogSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
  },
  helpType: {
    type: String,
    required: true,
  },
  priorityLevel: {
    type: String,
    enum: ["Low", "Medium", "High"],
    default: "Low",
  },
  date: {
    type: String,
    required: true,
  },
  time: {
    type: String,
    required: true,
  },
  area: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ["Active", "Done"],
    default: "Active",
  },
  respondingCount: {
    type: Number,
    default: 0,
  },
  responders: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  ],
}, { timestamps: true });

module.exports = mongoose.model("Blog", BlogSchema);