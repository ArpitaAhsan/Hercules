import 'package:flutter/material.dart';
import 'package:hercules/edit_profile.dart';
import 'package:hercules/home_page.dart';
import 'package:hercules/location_page.dart';
import 'package:hercules/login_page.dart';
import 'package:hercules/nearby_page.dart';
import 'package:hercules/register_page.dart';
import 'package:hercules/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const location = '/location';
  static const editProfile = '/edit_profile';
  static const profile = '/profile';
  static const nearby = '/nearby';
  static const register = '/register';

  // Define the routes
  static final pages = {
    login: (context) => LoginPage(),
    home: (context) => HomePage(),
    location: (context) => FutureBuilder<String?>(
      future: _getUserIdFromPrefs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('User ID not found'));
        } else {
          return LocationPage(); // Pass userId fetched in LocationPage
        }
      },
    ),
    editProfile: (context) => EditProfile(),
    profile: (context) {
      final scrollController = ModalRoute.of(context)?.settings.arguments as ScrollController?;
      return ProfilePage(
        scrollController: scrollController ?? ScrollController(),
        updatePageIndex: (index) {}, // Customize this callback
      );
    },
    nearby: (context) => NearbyPage(), // Directly use NearbyPage
    register: (context) => RegisterPage(),
  };

  static Future<String?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
