import 'package:flutter/material.dart';
import 'package:hercules/home_page.dart';
import 'package:hercules/profile_page.dart';
import 'package:hercules/nearby_page.dart';
import 'package:hercules/config/app_string.dart';
import 'package:hercules/styles/app_colors.dart';
import 'package:hercules/component/bottom_navigation_item.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hercules/profile_provider.dart';
import 'package:hercules/call_help.dart';
import 'package:hercules/activity_log.dart'; // Ensure ActivityLogPage is imported
import 'package:hercules/blog_post.dart';
import 'package:hercules/blog_feed.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Menus currentIndex = Menus.home;
  final ScrollController _scrollController = ScrollController();
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserIdFromPrefs();
  }

  Future<void> _fetchUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });

    if (userId != null) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.fetchUserProfile(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return userId == null
        ? const Center(child: CircularProgressIndicator()) // Loading state
        : Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        bool isEmergency = profileProvider.isEmergency;
        String emergencyAlertColor = profileProvider.emergencyAlertColor;
        LatLng emergencyLocation = LatLng(0.0, 0.0);

        if (isEmergency) {
          emergencyLocation = LatLng(
            profileProvider.emergencyLatitude,
            profileProvider.emergencyLongitude,
          );
        }

        final pages = [
          HomePage(),
          NearbyPage(), // Removed userId from the constructor
          Center(child: Text(AppString.message)),
          Center(child: Text(AppString.addPost)),
          ProfilePage(
            scrollController: _scrollController,
            updatePageIndex: updatePageIndex,
          ),
        ];

        return Scaffold(
          extendBody: true,
          body: SafeArea(
            child: pages[currentIndex.index],
          ),
          bottomNavigationBar: MyBottomNavigation(
            currentIndex: currentIndex,
            onTap: (value) {
              setState(() {
                currentIndex = value;
              });
            },
          ),
        );
      },
    );
  }

  void updatePageIndex(int index) {
    setState(() {
      currentIndex = Menus.values[index];
    });
  }
}

enum Menus {
  home,
  location,
  add,
  messages,
  user,
}

class MyBottomNavigation extends StatelessWidget {
  final Menus currentIndex;
  final ValueChanged<Menus> onTap;

  const MyBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 87,
      padding: EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () => onTap(Menus.home),
                      icon: Icons.home,
                      current: currentIndex,
                      name: Menus.home,
                    ),
                  ),
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () => onTap(Menus.location),
                      icon: Icons.location_on,
                      current: currentIndex,
                      name: Menus.location,
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () {
                        // Navigate to CallHelpPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CallHelpPage(),
                          ),
                        );
                      },
                      icon: Icons.message,
                      current: currentIndex,
                      name: Menus.messages,
                    ),
                  ),
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () {
                        // Navigate to ActivityLogPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActivityLogPage(),
                          ),
                        );
                      },
                      icon: Icons.person,
                      current: currentIndex,
                      name: Menus.user,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlogFeedPage(), // Create this next
                  ),
                );
              },

              child: Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
