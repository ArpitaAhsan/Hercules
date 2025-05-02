const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");

// Import database connection
const connectDB = require("./config/db");

dotenv.config();  // Load environment variables

const app = express();

// Middleware
app.use(express.json()); // Allows JSON parsing
app.use(cors({
    origin: "*", 
    credentials: true
}));

// Import Routes
const authRoutes = require("./routes/auth");

// Use Routes
app.use("/api/auth", authRoutes);

// Connect to MongoDB
connectDB();  // Establish MongoDB connection

const PORT = process.env.PORT || 9062;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));  // Fix string interpolation
 
 
