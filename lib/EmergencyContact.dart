import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactScreen extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': 'Fr. Roby', 'phone': '+91 9686018612'},
    {'name': 'Roy Joseph', 'phone': '+91 7776860002'},
    {'name': 'Hostel Reception', 'phone': '+91 9403554750'},
    {'name': 'Steavo Babu', 'phone': '+91 9699579704'},
    {'name': 'Atharva Men', 'phone': '+91 7499752762'},
    {'name': 'Omkar Gangamwar', 'phone': '+91 8766734653'},
    {'name': 'Om Gawande', 'phone': '+91 9766839371'},
    {'name': 'Gaurav Pidurkar', 'phone': '+91 8788498617'},
  ];

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contact'),
        backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
        automaticallyImplyLeading: true, // Show back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: Icon(Icons.person_rounded, size: 40), // Icon for Name
                title: Text(contact['name'] ?? 'Unknown Name'),
                trailing: IconButton(
                  icon: Icon(Icons.call_outlined, color: Colors.green),
                  onPressed: () => _launchPhone(contact['phone'] ?? ''),
                ),
                // subtitle: Text(contact['phone'] ?? 'Unknown Phone Number'),
              ),
            );
          },
        ),
      ),
    );
  }
}
