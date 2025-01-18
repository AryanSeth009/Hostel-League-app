import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

class RisingGiantsCaptain extends StatelessWidget {
  final String teamName = 'Rising Giants'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
        title: Text(teamName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(teamName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No members found'));
          }

          final documents = snapshot.data!.docs;

          // Sort documents alphabetically by 'name'
          documents.sort((a, b) {
            final nameA = a['name'] ?? '';
            final nameB = b['name'] ?? '';
            return nameA.compareTo(nameB);
          });

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final name = doc['name'] ?? 'Unnamed';
              final sports = List<String>.from(doc['sports'] ?? []);
              final documentId = doc.id;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (doc['player_status'] == "true") // Check if player_status is true
                          Text(
                            'Blocked', // Display Blocked if player_status is true
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red, 
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else ...[
                          for (var sport in sports)
                            Text(
                              sport,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberDetailsScreen(documentId: documentId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}



class MemberDetailsScreen extends StatelessWidget {
  final String documentId;

  MemberDetailsScreen({required this.documentId});

  // Function to launch the dialer with the provided phone number
  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
        title: Text('Member Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Rising Giants')
            .doc(documentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No details found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Unnamed';
          final phoneNumber = data['phone_number'] ?? 'N/A';
          final roomNumber = data['room_number'] ?? 'N/A';
          final year = data['year'] ?? 'N/A';
          final culturalActivity = data['cultural_activity'] ?? 'N/A';
          final sports = data['sports'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Name', 
                      style: TextStyle(fontSize: 14), 
                    ),
                    subtitle: Text(
                      name, 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Phone Number',
                      style: TextStyle(fontSize: 14), 
                    ),
                    subtitle: Text(
                      phoneNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.phone, color: Colors.green),
                      onPressed: () => _launchPhoneDialer(phoneNumber),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Room Number', 
                      style: TextStyle(fontSize: 14), 
                    ),
                    subtitle: Text(
                      roomNumber, 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Year', 
                      style: TextStyle(fontSize: 14), 
                    ),
                    subtitle: Text(
                      year, 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Cultural Activity', 
                      style: TextStyle(fontSize: 14), 
                    ),
                    subtitle: Text(
                      culturalActivity, 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Sports', 
                      style: TextStyle(fontSize: 14), 
                    ),
                    subtitle: Text(
                      sports.join(', '), 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
