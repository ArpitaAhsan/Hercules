import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hercules/services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  String name = "";
  String email = "";
  String phone = "";
  String country = "";
  bool isEmergency = false;
  String emergencyAlertColor = "none";
  double emergencyLatitude = 0.0;
  double emergencyLongitude = 0.0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> response = await ApiService.fetchUserProfile(userId);
      if (response.containsKey('error')) {
        print("❌ Error fetching profile: ${response['error']}");
      } else {
        name = response['name'];
        email = response['email'];
        phone = response['phone'];
        isEmergency = response['isEmergency'].toString().toLowerCase() == 'true';
        emergencyAlertColor = response['emergencyAlertColor'] ?? 'none';
        emergencyLatitude = response['emergencyLatitude'] ?? 0.0;
        emergencyLongitude = response['emergencyLongitude'] ?? 0.0;

        notifyListeners();
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}