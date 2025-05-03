import 'dart:convert'; // for json decoding
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hercules/profile_provider.dart';
import 'package:http/http.dart' as http;

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();
  bool _isLocationLoading = true;
  bool _isProfileFetched = false;
  String? _userId;
  List<dynamic> _activeAlerts = []; // List to store active alerts
  String _rawResponse = ''; // To store the raw API response
  String _errorMessage = ''; // To store error messages

  // NEW: Dropdown filter variables
  String _selectedEmergencyType = 'All';

  final Map<String, String> _emergencyTypeColors = {
    'General Emergency': 'red',
    'Rape': 'purple',
    'Riot': 'brown',
    'Mugging': 'yellow',
    'Fire': 'orange',
    'Domestic Violence': 'green',
  };

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    await _getUserIdFromPrefs();
    if (_userId != null) {
      await _determinePosition();
      await _fetchUserProfile();
      await _fetchActiveAlerts(); // Fetch active alerts from backend
    } else {
      print("❌ User ID not found in SharedPreferences.");
    }
  }

  Future<void> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  Future<void> _fetchUserProfile() async {
    if (_userId == null) return;

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.fetchUserProfile(_userId!);
    setState(() {
      _isProfileFetched = true;
    });
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLocationLoading = false;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', position.latitude);
    prefs.setDouble('longitude', position.longitude);
  }
  //  active alert gula dekhanor jonno map e
  Future<void> _fetchActiveAlerts() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.103:9062/api/auth/active-alerts'));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          _activeAlerts = json.decode(response.body);
          _rawResponse = response.body;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _rawResponse = '';
          _errorMessage = 'Failed to fetch active alerts. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _rawResponse = '';
        _errorMessage = 'Error fetching active alerts: $e';
      });
    }
  }

  Color _getEmergencyColor(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _showAlertDetailsDialog(BuildContext context, dynamic alert) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Emergency Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Emergency Type: ${alert['emergencyType']}'),
              Text('Alert Color: ${alert['alertColor']}'),
              if (alert['location'] != null)
                Text('Location: (${alert['location']['coordinates'][0]}, ${alert['location']['coordinates'][1]})'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isLoading = _isLocationLoading || !_isProfileFetched || profileProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Locations')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // NEW: Dropdown filter button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedEmergencyType,
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All')),
                    ..._emergencyTypeColors.keys.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedEmergencyType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? LatLng(0, 0),
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        width: 50,
                        height: 50,
                        point: _currentPosition!,
                        child: profileProvider.isEmergency
                            ? GestureDetector(
                          onTap: () => _showAlertDetailsDialog(context, profileProvider),
                          child: _BlinkingAnimatedIcon(
                            color: _getEmergencyColor(profileProvider.emergencyAlertColor),
                            icon: Icons.location_pin,
                          ),
                        )
                            : Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ..._activeAlerts
                        .where((alert) {
                      if (_selectedEmergencyType == 'All') return true;
                      return alert['emergencyType']?.toString().toLowerCase() ==
                          _selectedEmergencyType.toLowerCase();
                    })
                        .map<Marker?>((alert) {
                      final alertCoordinates = alert['location']?['coordinates'];
                      if (alertCoordinates != null && alertCoordinates.length == 2) {
                        final alertLat = alertCoordinates[1] is double
                            ? alertCoordinates[1]
                            : alertCoordinates[1].toDouble();
                        final alertLng = alertCoordinates[0] is double
                            ? alertCoordinates[0]
                            : alertCoordinates[0].toDouble();

                        return Marker(
                          width: 50,
                          height: 50,
                          point: LatLng(alertLat, alertLng),
                          child: GestureDetector(
                            onTap: () => _showAlertDetailsDialog(context, alert),
                            child: Icon(
                              Icons.circle,
                              color: _getEmergencyColor(alert['alertColor']),
                              size: 20,
                            ),
                          ),
                        );
                      } else {
                        return null;
                      }
                    })
                        .whereType<Marker>()
                        .toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingAnimatedIcon extends StatefulWidget {
  final Color color;
  final IconData icon;

  const _BlinkingAnimatedIcon({
    required this.color,
    required this.icon,
  });

  @override
  State<_BlinkingAnimatedIcon> createState() => _BlinkingAnimatedIconState();
}

class _BlinkingAnimatedIconState extends State<_BlinkingAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 1.0, end: 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Icon(
        widget.icon,
        color: widget.color,
        size: 40,
      ),
    );
  }
}