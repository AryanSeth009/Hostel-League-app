import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DevelopersScreen extends StatelessWidget {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined order of developers' names
  final List<String> developerOrder = ['Kushal Khadgi', 'Abhishek Wasekar', 'Nakul Wanjari'];

  // Method to launch the dialer
  void _launchDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  // Method to launch WhatsApp
  void _launchWhatsApp(String phoneNumber) async {
    String whatsappUrl = 'https://wa.me/${phoneNumber.replaceAll('+', '')}';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      throw 'Could not launch WhatsApp for $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
        title: Text('Developers Contact'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('developers').snapshots(), // Fetch all developers from Firestore
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final developers = snapshot.data!.docs;

          // Sort developers according to the predefined order
          developers.sort((a, b) {
            final aName = (a.data() as Map<String, dynamic>)['name'] as String;
            final bName = (b.data() as Map<String, dynamic>)['name'] as String;
            return developerOrder.indexOf(aName).compareTo(developerOrder.indexOf(bName));
          });

          return ListView.builder(
            itemCount: developers.length,
            itemBuilder: (context, index) {
              final developerDoc = developers[index].data() as Map<String, dynamic>;
              final name = developerDoc['name'] as String; 
              final phone = developerDoc['phone'] as String; 
              final imageUrl = developerDoc['imageUrl'] as String? ?? ''; 

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    children: [
                      // Image with 4:3 Aspect Ratio or Fallback Avatar
                      AspectRatio(
                        aspectRatio: 4 / 3, // Set the aspect ratio to 4:3
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildFallbackAvatar(name);
                                  },
                                )
                              : _buildFallbackAvatar(name), 
                        ),
                      ),
                      ListTile(
                        title: Text(
                          name,
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // WhatsApp Icon Button
                            IconButton(
                              icon: Icon(Icons.wechat_outlined),
                              onPressed: () => _launchWhatsApp(phone),
                            ),
                            // Call Icon Button
                            IconButton(
                              icon: Icon(Icons.call_outlined),
                              onPressed: () => _launchDialer(phone),
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

  Widget _buildFallbackAvatar(String name) {
    return Center(
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
        child: Text(
          name[0], 
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
