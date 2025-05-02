const mongoose = require("mongoose");

const AlertSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  emergencyType: {
    type: String,
    required: true,
  },
  alertColor: {
    type: String,
    default: "red",
  },
  isEmergency: {
    type: Boolean,
    default: true,
  },
    location: {
    type: {
      type: String,
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [0, 0],
    },
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  finishedAt: {
    type: Date,
    default: null,
  },
});

AlertSchema.index({ location: "2dsphere" });
module.exports = mongoose.model("Alert", AlertSchema);
