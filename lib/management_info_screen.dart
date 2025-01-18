import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ManagementInfoScreen extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': 'Uday Rudrakar', 'phone': '+91 8698575167'},
    {'name': 'Kushal Khadgi', 'phone': '+91 7058065928'},
    {'name': 'Nakul Wanjari', 'phone': '+91 9356304607'},
    {'name': 'Kevin Beji', 'phone': '+91 9718862960'},
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
         backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
        title: Text('Management Team'),
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
