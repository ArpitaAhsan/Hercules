import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hercules/profile_page.dart';
import 'package:hercules/nearby_page.dart';

const String apiBaseUrl = "http://192.168.0.103:9062"; // Your local backend

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  final ScrollController scrollController = ScrollController();
  List<dynamic> alerts = [];
  bool isLoading = true;
  String? loggedInUserId;
  String? loggedInEmail;

  @override
  void initState() {
    super.initState();
    loadUserInfoAndFetchAlerts();
  }

  void updatePageIndex(int index) {
    // Handle tab switch if needed
  }

  Future<void> loadUserInfoAndFetchAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    final storedEmail = prefs.getString('email');

    if (storedUserId != null) {
      setState(() {
        loggedInUserId = storedUserId;
        loggedInEmail = storedEmail ?? "unknown@example.com";
      });
      await fetchAlerts(storedUserId);
    } else {
      print("User ID not found in SharedPreferences");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAlerts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/auth/alerts/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          alerts = data;
          isLoading = false;
        });
      } else {
        print("Failed to load alerts: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching alerts: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> submitFeedback(String emergencyType) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController feedbackController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email TextField
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email...',
              ),
            ),
            const SizedBox(height: 10),
            // Feedback TextField
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                hintText: 'Enter your feedback here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final feedbackText = feedbackController.text.trim();

              if (email.isEmpty || feedbackText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Both email and feedback are required')),
                );
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse('$apiBaseUrl/api/auth/feedback/create'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'email': email, // Use the email entered by the user
                    'emergencyType': emergencyType,
                    'feedback': feedbackText,
                  }),
                );

                if (response.statusCode == 201) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback submitted!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit feedback: ${response.statusCode}')),
                  );
                }
              } catch (e) {
                print("Error submitting feedback: $e");
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> markAlertAsDone(String alertId, String emergencyType) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/api/auth/alert/finish/$alertId'),
      );

      if (response.statusCode == 200) {
        print('Alert marked as finished');

        setState(() {
          alerts = alerts.map((alert) {
            if (alert['_id'] == alertId) {
              alert['finishedAt'] = DateTime.now().toIso8601String();
              alert['alertColor'] = 'grey';
            }
            return alert;
          }).toList();
        });

        await submitFeedback(emergencyType); // Show feedback form after marking done

        // Optional: redirect after short delay
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NearbyPage()),
        );
      } else {
        print("Failed to mark alert as finished: ${response.statusCode}");
      }
    } catch (e) {
      print("Error marking alert as finished: $e");
    }
  }

  Widget buildAlertCard(dynamic alert) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      color: alert['isEmergency'] == true ? Colors.red[100] : Colors.grey[200],
      child: ListTile(
        title: Text(
          "Type: ${alert['emergencyType'] ?? 'Unknown'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Created: ${alert['createdAt'] ?? 'N/A'}"),
        trailing: alert['finishedAt'] != null
            ? const Text("Finished", style: TextStyle(color: Colors.green))
            : ElevatedButton(
          onPressed: () => markAlertAsDone(alert['_id'], alert['emergencyType']),
          child: const Text("Done"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade300,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Log"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'goToProfile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      scrollController: scrollController,
                      updatePageIndex: updatePageIndex,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'goToProfile',
                child: Text('Go to Profile'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
          ? const Center(child: Text("No alerts found."))
          : ListView.builder(
        controller: scrollController,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return buildAlertCard(alerts[index]);
        },
      ),
    );
  }
}
