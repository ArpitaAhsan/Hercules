import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackModel {
  final String email;
  final String emergencyType;
  final String feedback;
  final String createdAt;

  FeedbackModel({
    required this.email,
    required this.emergencyType,
    required this.feedback,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      email: json['email'],
      emergencyType: json['emergencyType'],
      feedback: json['feedback'],
      createdAt: json['createdAt'],
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late Future<List<FeedbackModel>> feedbacks;

  @override
  void initState() {
    super.initState();
    feedbacks = fetchFeedbacks();
  }

  Future<List<FeedbackModel>> fetchFeedbacks() async {
    const String apiUrl = 'http://192.168.0.114:1518/api/auth/feedback/all'; // <-- Update this with your actual backend URL

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> feedbackJson = json.decode(response.body);
      return feedbackJson.map((json) => FeedbackModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load feedbacks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Feedbacks')),
      body: FutureBuilder<List<FeedbackModel>>(
        future: feedbacks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No feedbacks found'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final fb = data[index];
              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                child: ListTile(
                  title: Text(fb.email),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency: ${fb.emergencyType}'),
                      const SizedBox(height: 4),
                      Text('Feedback: ${fb.feedback}'),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${DateTime.parse(fb.createdAt).toLocal().toString()}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}