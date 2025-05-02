import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:hercules/profile_provider.dart';

class BlogPostPage extends StatefulWidget {
  const BlogPostPage({super.key});

  @override
  State<BlogPostPage> createState() => _BlogPostPageState();
}

class _BlogPostPageState extends State<BlogPostPage> {
  List<dynamic> blogPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    setState(() => isLoading = true);
    final url = Uri.parse("http://192.168.153.203:9308/api/auth/active");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          blogPosts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching blogs: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> markBlogAsDone(String blogId) async {
    final url = Uri.parse("http://192.168.153.203:9308/api/auth/done/$blogId");

    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        fetchBlogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blog marked as done')),
        );
      } else {
        print("Error marking blog as done: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> createBlogPost(
      String email,
      String helpType,
      String priority,
      String area,
      String date,
      String time,
      ) async {
    final url = Uri.parse("http://192.168.153.203:9308/api/auth/create");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "helpType": helpType,
          "priorityLevel": priority,
          "date": date,
          "time": time,
          "area": area,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Blog posted successfully")),
        );
        fetchBlogs();
      } else {
        print("Failed to post blog: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to post blog")),
        );
      }
    } catch (e) {
      print("Error posting blog: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error posting blog")),
      );
    }
  }

  Future<void> respondToBlog(String blogId) async {
    final email = Provider.of<ProfileProvider>(context, listen: false).email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not found')),
      );
      return;
    }

    // Fetch the user's ObjectId from their email address
    final url = Uri.parse("http://192.168.153.203:9308/api/auth/getUserIdByEmail/$email");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userId = data['userId'];  // Assuming the response contains the userId

        // Now, send the user's ObjectId with the blog response
        final respondUrl = Uri.parse("http://192.168.153.203:9308/api/auth/respond/$blogId/$userId");

        final respondResponse = await http.post(respondUrl);
        if (respondResponse.statusCode == 200) {
          // Find the blog post by ID and update the responding count
          setState(() {
            final index = blogPosts.indexWhere((blog) => blog['_id'] == blogId);
            if (index != -1) {
              blogPosts[index]['respondingCount'] += 1;  // Increment the responding count locally
              blogPosts[index]['responders'].add(userId);  // Add the userId to the responders list
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Responded successfully')),
          );
        } else {
          print("Error responding: ${respondResponse.body}");
        }
      } else {
        print("Error fetching userId: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }






  void showBlogFormDialog(String email) {
    final _formKey = GlobalKey<FormState>();
    final helpTypeController = TextEditingController();
    final priorityController = TextEditingController();
    final areaController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Emergency Help Post"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: helpTypeController,
                    decoration: const InputDecoration(labelText: "Help Type"),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: priorityController,
                    decoration: const InputDecoration(labelText: "Priority"),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: areaController,
                    decoration: const InputDecoration(labelText: "Area"),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "Time (HH:mm)"),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  await createBlogPost(
                    email,
                    helpTypeController.text,
                    priorityController.text,
                    areaController.text,
                    dateController.text,
                    timeController.text,
                  );
                }
              },
              child: const Text("Post"),
            ),
          ],
        );
      },
    );
  }

  Widget buildPostCard(dynamic blog, String? currentEmail) {
    bool isOwner = blog['email'] == currentEmail;
    List<dynamic> responders = blog['responders'] ?? [];
    bool hasResponded = responders.contains(currentEmail);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog['email'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text("Help Type: ${blog['helpType']}"),
            Text("Priority: ${blog['priorityLevel']}"),
            Text("Area: ${blog['area']}"),
            const SizedBox(height: 8),
            Text(
              "Status: ${blog['status']}",
              style: TextStyle(
                color: blog['status'] == "Done" ? Colors.grey : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${blog['respondingCount'] ?? 0} responding"),
                const Spacer(),
                Text(
                  "${blog['date']} ${blog['time']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isOwner && blog['status'] != 'Done')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => markBlogAsDone(blog['_id']),
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text("Finish", style: TextStyle(color: Colors.green)),
                ),
              )
            else if (!isOwner && !hasResponded)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await respondToBlog(blog['_id']);
                  },
                  icon: const Icon(Icons.handshake, color: Colors.blue),
                  label: const Text("Respond", style: TextStyle(color: Colors.blue)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final email = profileProvider.email;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Emergency Posts"),
            backgroundColor: Colors.redAccent,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : email.isEmpty
              ? const Center(child: Text("Loading user info..."))
              : RefreshIndicator(
            onRefresh: fetchBlogs,
            child: ListView.builder(
              itemCount: blogPosts.length,
              itemBuilder: (context, index) =>
                  buildPostCard(blogPosts[index], email),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showBlogFormDialog(email),
            child: const Icon(Icons.add),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );
  }
}
