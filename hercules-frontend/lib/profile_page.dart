import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hercules/config/app_routes.dart';
import 'package:hercules/profile_provider.dart';
import 'package:hercules/change_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final ScrollController scrollController;
  final Function(int) updatePageIndex;

  const ProfilePage({super.key, required this.scrollController, required this.updatePageIndex});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.fetchUserProfile(userId);
    } else {
      print("❌ No user ID found in SharedPreferences");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
          body: CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profileProvider.name.isNotEmpty ? profileProvider.name : "Loading...",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileProvider.email.isNotEmpty ? profileProvider.email : "Loading email...",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 20),
                    _buildSectionTitle("Account", context),

                    _buildProfileOption(
                      context,
                      icon: Icons.person_outline,
                      title: "Edit Profile",
                      subtitle: "Update your personal details",
                      onTap: () {
                        // Navigate to Edit Profile
                        Navigator.pushNamed(context, AppRoutes.editProfile);
                      },
                    ),

                    _buildProfileOption(
                      context,
                      icon: Icons.lock_outline,
                      title: "Change Password",
                      subtitle: "Update your password for security",
                      onTap: () {
                        // Navigate to Change Password screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                        );
                      },
                    ),


                    const SizedBox(height: 20),
                    _buildSectionTitle("Preferences", context),

                    _buildProfileOption(
                      context,
                      icon: Icons.notifications_outlined,
                      title: "Permission Settings",
                      subtitle: "Manage your permissions",
                      onTap: () => print("Navigate to Permission Settings"),
                    ),

                    _buildProfileOption(
                      context,
                      icon: Icons.color_lens_outlined,
                      title: "Theme",
                      subtitle: "Choose your preferred theme",
                      onTap: () => print("Navigate to Theme Selector"),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("Activity", context),

                    _buildProfileOption(
                      context,
                      icon: Icons.history_outlined,
                      title: "Service History",
                      subtitle: "Check your past services",
                      onTap: () => print("Navigate to Service History"),
                    ),

                    _buildProfileOption(
                      context,
                      icon: Icons.star_outline,
                      title: "Your Reviews",
                      subtitle: "Manage and view your reviews",
                      onTap: () => print("Navigate to Your Reviews"),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("Support", context),

                    _buildProfileOption(
                      context,
                      icon: Icons.help_outline,
                      title: "Help & Feedback",
                      subtitle: "Contact us for assistance",
                      onTap: () => print("Navigate to Help & Feedback"),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("Logout", context),

                    _buildProfileOption(
                      context,
                      icon: Icons.login_outlined,
                      iconColor: Colors.red,
                      title: "Log Out",
                      titleColor: Colors.red,
                      subtitle: "Log out of your account",
                      onTap: () => _showLogOutDialog(context),
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Section Titles
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Profile Option Cards with border
  Widget _buildProfileOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        Color? iconColor,
        Color? titleColor,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),  // Adding border here
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: iconColor ?? Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? Theme.of(context).textTheme.bodyLarge!.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Show Log Out Dialog
  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to log out?'),
          content: const Text('You will be redirected to the login page.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login, (route) => false,
                );
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
