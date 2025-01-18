import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class ManagementGrievanceScreen extends StatelessWidget {
  const ManagementGrievanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
       backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
      title: const Text('Grievance'),
    ),
    body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('grievances').orderBy('submittedAt', descending: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching grievances'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No grievances found'));
        }

        // Build a list of tiles
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Grievance grievance = Grievance.fromFirestore(doc);

            // Determine text color based on status
            Color statusColor;
            if (grievance.status == 'Approved') {
              statusColor = Colors.green;
            } else if (grievance.status == 'Rejected') {
              statusColor = Colors.red;
            } else {
              statusColor = Colors.grey; // Default color for other statuses
            }

            return ListTile(
              title: Text(grievance.matchId), // Show Match ID as the title
              subtitle: Text('Name: ${grievance.name}'), // Show Name as the subtitle
              leading: const Icon(Icons.report_problem),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    grievance.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Navigate to the detail screen and pass the grievance details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrievanceDetailScreen(grievance: grievance),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    ),
  );
}

}


class GrievanceDetailScreen extends StatelessWidget {
  final Grievance grievance;

  const GrievanceDetailScreen({super.key, required this.grievance});

  @override
  Widget build(BuildContext context) {
    // Format the date to exclude time
    String formattedDate = DateFormat('yyyy-MM-dd').format(grievance.submittedAt.toDate());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grievance Details'),
        backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: const Text('Name'),
                  subtitle: Text(
                    grievance.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.group, color: Colors.blueAccent),
                  title: const Text('Team'),
                  subtitle: Text(
                    grievance.team,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.vpn_key, color: Colors.blueAccent),
                  title: const Text('Match ID'),
                  subtitle: Text(
                    grievance.matchId,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.report_problem, color: Colors.blueAccent),
                  title: const Text('Related To'),
                  subtitle: Text(
                    grievance.grievanceRelatedTo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.blueAccent),
                  title: const Text('Grievance Message'),
                  subtitle: Text(
                    grievance.grievanceMessage,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.blueAccent),
                  title: const Text('Has Proof'),
                  subtitle: Text(
                    grievance.hasProof,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  title: const Text('Submitted At'),
                  subtitle: Text(
                    formattedDate,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.blueAccent),
                  title: const Text('Status'),
                  subtitle: Text(
                    grievance.status,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




class Grievance {
  final String name;
  final String team;
  final String matchId;
  final String grievanceRelatedTo;
  final String grievanceMessage;
  final String hasProof;
  final Timestamp submittedAt;
  final String status;

  Grievance({
    required this.name,
    required this.team,
    required this.matchId,
    required this.grievanceRelatedTo,
    required this.grievanceMessage,
    required this.hasProof,
    required this.submittedAt,
    required this.status,
  });

  factory Grievance.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Grievance(
      name: data['name'] ?? '',
      team: data['team'] ?? '',
      matchId: data['matchId'] ?? '',
      grievanceRelatedTo: data['grievanceRelatedTo'] ?? '',
      grievanceMessage: data['grievanceMessage'] ?? '',
      hasProof: data['hasProof'] ?? '',
      submittedAt: data['submittedAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'Pending', // Default to 'Pending' if not provided
    );
  }
}