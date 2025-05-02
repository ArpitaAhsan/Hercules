import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class CallHelpPage extends StatelessWidget {
  const CallHelpPage({super.key});

  // Function to launch the dialer with the number pre-filled for police
  Future<void> _callPolice() async {
    const String policeNumber = '01919'; // The police contact number

    // Create a URL scheme to open the dialer with the police number
    final Uri phoneUri = Uri.parse('tel:$policeNumber');

    // Check if the device can launch the phone dialer
    if (await canLaunch(phoneUri.toString())) {
      // Launch the dialer with the pre-filled number
      await launch(phoneUri.toString());
    } else {
      // If the device cannot launch the dialer, show an error
      print('Could not launch the dialer');
    }
  }

  // Function to launch the dialer with the number pre-filled for fire brigade
  Future<void> _callFireBrigade() async {
    const String fireBrigadeNumber = '01819'; // The fire brigade contact number

    // Create a URL scheme to open the dialer with the fire brigade number
    final Uri phoneUri = Uri.parse('tel:$fireBrigadeNumber');

    // Check if the device can launch the phone dialer
    if (await canLaunch(phoneUri.toString())) {
      // Launch the dialer with the pre-filled number
      await launch(phoneUri.toString());
    } else {
      // If the device cannot launch the dialer, show an error
      print('Could not launch the dialer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call for Help'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Calling for help...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            // Add the 'Call Police' button
            ElevatedButton(
              onPressed: _callPolice, // Call police when pressed
              child: Text(
                'Call Police',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set red color for police button
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            // Add the 'Call Fire Brigade' button
            ElevatedButton(
              onPressed: _callFireBrigade, // Call fire brigade when pressed
              child: Text(
                'Call Fire Brigade',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Set orange color for fire brigade button
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
