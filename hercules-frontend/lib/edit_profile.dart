import 'package:flutter/material.dart';
import 'package:hercules/component/toolbar.dart';
import 'package:hercules/component/app_text_field.dart';
import 'package:hercules/config/app_string.dart';
import 'package:hercules/styles/app_colors.dart';
import 'package:hercules/services/api_service.dart'; // Import the ApiService
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hercules/config/app_routes.dart';

class EditProfile extends StatefulWidget {
  EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String userId = "";  // To store dynamic userId

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Load the user ID from shared preferences
  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? "";
    });

    // After loading the userId, fetch the user's current profile
    if (userId.isNotEmpty) {
      _fetchUserProfile(userId);
    }
  }

  // Fetch the current user profile from the API
  void _fetchUserProfile(String userId) async {
    final response = await ApiService.fetchUserProfile(userId);
    if (response['error'] == null) {
      _nameController.text = response['name'];
      _phoneController.text = response['phone'];
      _countryController.text = response['country'];
    } else {
      // Handle error if fetching profile failed
      print("❌ Error fetching profile: ${response['error']}");
    }
  }

  // Update Profile function
  void _updateProfile() async {
    final response = await ApiService.updateUserProfile(
      userId: userId,
      name: _nameController.text,
      phone: _phoneController.text,
      country: _countryController.text,
    );

    if (response['error'] == null) {
      // Navigate to Profile Page after successful update
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.profile, (route) => false);
    } else {
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['error'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Toolbar(title: AppString.editProfile),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 60),
              AppTextField(
                hint: "Name", // Updated field
                controller: _nameController,
              ),
              SizedBox(height: 16),
              AppTextField(
                hint: "Phone Number", // Updated field
                controller: _phoneController,
              ),
              SizedBox(height: 16),
              AppTextField(
                hint: "Country", // Updated field
                controller: _countryController,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
