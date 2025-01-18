import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CaptainScreen extends StatelessWidget {
  // A list of teams
  final List<String> _teams = [
    'Black Eagles',
    'Anna Warriors',
    'Defending Titans',
    'White Walkers',
    'The Scout Regiment',
    'Retro Rivals',
    'Rising Giants',
  ];

  // A list of captain contacts for each team
  final List<Map<String, String>> Captaincontacts = [
    {'name': 'Firdous Khan', 'phone': '+91 9103283623'},
    {'name': 'Joseph Binoy', 'phone': '+91 7048913545'},
    {'name': 'Abhishek Sharma', 'phone': '+91 8275928185'},
    {'name': 'Vishal Thakrele', 'phone': '+91 9309704830'},
    {'name': 'Mohit Deshmukh', 'phone': '+91 8966878539'},
    {'name': 'Mohammed Ali', 'phone': '+91 9309105003'},
    {'name': 'Nishant Ghugal', 'phone': '+91 9309327670'},
  ];

  // A list of vice-captain contacts for each team
  final List<Map<String, String>> ViceCaptaincontacts = [
    {'name': 'Lawrence Anthony', 'phone': '+91 8103055751'},
    {'name': 'Abhishek Wasekar', 'phone': '+91 7720986890'},
    {'name': 'Shantnu Fartode', 'phone': '+91 9604650588'},
    {'name': 'Tejas Ukey', 'phone': '+91 7038484303'},
    {'name': 'Ayush Tayade', 'phone': '+91 9322067169'},
    {'name': 'Pranay Masurkar', 'phone': '+91 8767397213'},
    {'name': 'Anurag Kukde', 'phone': '+91 9359265308'},
  ];

  // Method to launch the dialer
  void _launchDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
        title: Text('Captains Contact'),
        
      ),
      body: ListView.builder(
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: [
                  // Main parent Tile for the team name
                  ListTile(
                    title: Text(
                      _teams[index], // Team name as the title
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(height: 1), 
                  ListTile(
                    title: Text(
                      '${Captaincontacts[index]['name']!}', // Captain's name
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () => _launchDialer(Captaincontacts[index]['phone']!), // Captain's phone
                    ),
                  ),
                  
                  ListTile(
                    title: Text(
                      '${ViceCaptaincontacts[index]['name']!}', // Vice captain's name
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () => _launchDialer(ViceCaptaincontacts[index]['phone']!), // Vice captain's phone
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
