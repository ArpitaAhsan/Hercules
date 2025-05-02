import 'package:flutter/material.dart';
import 'package:hercules/blog_post.dart'; // Make sure this file exists and has BlogPage defined
import 'feedback_page.dart'; // We’ll create this next

class BlogFeedPage extends StatefulWidget {
  const BlogFeedPage({super.key});

  @override
  State<BlogFeedPage> createState() => _BlogFeedPageState();
}

class _BlogFeedPageState extends State<BlogFeedPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // We have 2 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blogs & Feedbacks'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Blogs'),
              Tab(text: 'Feedbacks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BlogPostPage(),
            FeedbackPage(),
          ],
        ),
      ),
    );
  }
}
