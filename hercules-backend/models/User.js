const mongoose = require("mongoose");

// Define the schema for User
const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  phone: {
    type: String, // Store the phone number
    required: true,
  },
  country: {
    type: String, // Store the selected country
    required: true,
  },
  
  // New fields for emergency state
  isEmergency: {
    type: Boolean,
    default: false, // Default is false (user not in an emergency state)
  },
  emergencyAlertColor: {
    type: String,
    default: 'none', // Default is 'none', no color set initially
  },
  emergencyLocation: {
    type: {
      type: String,  // GeoJSON type to store coordinates
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [null, null], // Default to null coordinates
    },
  },
});

module.exports = mongoose.model("User", UserSchema);
