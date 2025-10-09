import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Import for JSON decoding
import 'package:flutter/services.dart'; // Import for rootBundle

class CaptainScreen extends StatelessWidget {
  // Method to launch the dialer
  void _launchDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  // Method to launch the email client
  void _launchEmail(String emailAddress) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: emailAddress);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailAddress';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
        title: Text('Captains Contact'),
      ),
      body: FutureBuilder(
        future: rootBundle.loadString('lib/team_captains_data.json'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No captain data found.'));
          }

          final Map<String, dynamic> data = jsonDecode(snapshot.data as String);
          final List<String> teams = data.keys.toList();

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final String teamName = teams[index];
              final Map<String, dynamic> teamData = data[teamName];

              final String captainName = teamData['captainName'] ?? 'N/A';
              final String captainPhone = teamData['captainPhoneNumber'] ?? 'N/A';
              final String captainEmail = teamData['captainEmail'] ?? 'N/A';

              final String viceCaptainName = teamData['viceCaptainName'] ?? 'N/A';
              final String viceCaptainPhone = teamData['viceCaptainPhoneNumber'] ?? 'N/A';
              final String viceCaptainEmail = teamData['viceCaptainEmail'] ?? 'N/A';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          teamName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(height: 1),
                      ListTile(
                        title: Text(
                          'Captain: $captainName',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.call),
                              onPressed: captainPhone != 'N/A'
                                  ? () => _launchDialer(captainPhone)
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(Icons.email),
                              onPressed: captainEmail != 'N/A'
                                  ? () => _launchEmail(captainEmail)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Vice-Captain: $viceCaptainName',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.call),
                              onPressed: viceCaptainPhone != 'N/A'
                                  ? () => _launchDialer(viceCaptainPhone)
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(Icons.email),
                              onPressed: viceCaptainEmail != 'N/A'
                                  ? () => _launchEmail(viceCaptainEmail)
                                  : null,
                            ),
                          ],
                        ),
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
