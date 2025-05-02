import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hercules/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _helpButtonTapCount = 0;
  Map<String, String> emergencyTypes = {
    '🟣 Rape': 'purple',
    '🟡 Mugging': 'yellow',
    '🟤 Riot': 'brown',
    '🟠 Fire': 'orange',
    '🟢 Domestic Abuse': 'green',
  };

  Map<String, int> _tapCounts = {
    '🟣 Rape': 0,
    '🟡 Mugging': 0,
    '🟤 Riot': 0,
    '🟠 Fire': 0,
    '🟢 Domestic Abuse': 0,
  };

  Future<void> _onHelpButtonTapped() async {
    _helpButtonTapCount++;

    if (_helpButtonTapCount >= 3) {
      _helpButtonTapCount = 0;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      // Retrieve the current location from SharedPreferences
      final latitude = prefs.getDouble('latitude');
      final longitude = prefs.getDouble('longitude');

      if (userId != null && latitude != null && longitude != null) {
        const emergencyType = 'General Emergency';
        const alertColor = 'red';

        final logResponse = await ApiService.logEmergencyAlert(
          userId: userId,
          emergencyType: emergencyType,
          alertColor: alertColor,
          location: {
            'type': 'Point',
            'coordinates': [longitude, latitude],
          },
        );

        if (!logResponse.containsKey('error')) {
          await ApiService.updateEmergencyStatus(
            userId: userId,
            isEmergency: true,
            emergencyAlertColor: alertColor,
          );

          await ApiService.triggerEmergency(userId);

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/nearby');
          }
        } else {
          print("❌ Error: ${logResponse['error']}");
        }
      } else {
        print("⚠️ User ID or location not found.");
      }
    }
  }

  Future<void> _handleEmergency(String emergencyType) async {
    _tapCounts[emergencyType] = (_tapCounts[emergencyType] ?? 0) + 1;

    if (_tapCounts[emergencyType]! >= 2) {
      _tapCounts[emergencyType] = 0;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final latitude = prefs.getDouble('latitude');
      final longitude = prefs.getDouble('longitude');
      final color = emergencyTypes[emergencyType]!;

      if (userId != null && latitude != null && longitude != null) {
        final location = {
          'type': 'Point',
          'coordinates': [longitude, latitude],
        };

        // Log the emergency alert
        final response = await ApiService.logEmergencyAlert(
          userId: userId,
          emergencyType: emergencyType.replaceAll(RegExp(r'[^\w\s]+'), '').trim(),
          alertColor: color,
          location: location,
        );

        if (!response.containsKey('error')) {
          // Update the emergency status
          await ApiService.updateEmergencyStatus(
            userId: userId,
            isEmergency: true,
            emergencyAlertColor: color,
          );

          // Trigger the emergency (e.g., send notifications or alert systems)
          await ApiService.triggerEmergency(userId);

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/nearby');
          }
        } else {
          print("❌ Error logging alert: ${response['error']}");
        }
      } else {
        print("⚠️ User ID or location not found.");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(
              'assets/hercules_logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              print('Notification clicked');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: _onHelpButtonTapped,
          child: Column(
            children: [
              SizedBox(height:80),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  height: 350,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12.0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'HELP!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tap quickly 3 or more times to ask for help.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Or scroll down and tap an emergency type twice:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ...emergencyTypes.keys.map((String value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      _handleEmergency(value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
