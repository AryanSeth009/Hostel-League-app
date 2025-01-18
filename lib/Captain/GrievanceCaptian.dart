import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class CaptainGrievanceScreen extends StatelessWidget {
  const CaptainGrievanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Grievance'),
      backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
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
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GrievanceFormPage()),
        );
      },
      label: const Text('Raise a Grievance'),
      icon: const Icon(Icons.add),
      backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
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


class GrievanceFormPage extends StatefulWidget {
  const GrievanceFormPage({super.key});

  @override
  _GrievanceFormPageState createState() => _GrievanceFormPageState();
}


class _GrievanceFormPageState extends State<GrievanceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _matchIdController = TextEditingController();
  final TextEditingController _grievanceController = TextEditingController();

  String? _selectedTeam;
  String? _grievanceRelatedTo;
  String? _hasProof;

  // Function to store the grievance data in Firestore
  Future<void> _submitGrievance() async {
    final docGrievance = FirebaseFirestore.instance.collection('grievances').doc();
    // print('Submitting grievance data...');

    Map<String, dynamic> grievanceData = {
      'name': _nameController.text,
      'team': _selectedTeam ?? 'No team selected',
      'matchId': _matchIdController.text,
      'grievanceRelatedTo': _grievanceRelatedTo ?? 'Not specified',
      'grievanceMessage': _grievanceController.text,
      'hasProof': _hasProof ?? 'No proof provided',
      'submittedAt': Timestamp.now(),
      'status': 'Pending',
    };

    try {
      await docGrievance.set(grievanceData);
      print('Grievance submitted successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grievance Submitted Successfully')),
      );
      _nameController.clear();
      _matchIdController.clear();
      _grievanceController.clear();
      setState(() {
        _selectedTeam = null;
        _grievanceRelatedTo = null;
        _hasProof = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting grievance: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matchIdController.dispose();
    _grievanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
        title: const Text('Grievance Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Team Name Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedTeam,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>[
                    'Black Eagles',
                    'Anna Warriors',
                    'Defending Titans',
                    'White Walkers',
                    'The Scout Regiment',
                    'Retro Rivals',
                    'Rising Giants',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTeam = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your team name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Match ID Field
                TextFormField(
                  controller: _matchIdController,
                  decoration: const InputDecoration(
                    labelText: 'Match ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the match ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Grievance Related To (Dropdown)
                DropdownButtonFormField<String>(
                  value: _grievanceRelatedTo,
                  decoration: const InputDecoration(
                    labelText: 'Grievance Related To',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['Biased Decision', 'Unfair Play', 'Banned Player', 'Others']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _grievanceRelatedTo = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select the grievance type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Grievance Message
                TextFormField(
                  controller: _grievanceController,
                  decoration: const InputDecoration(
                    labelText: 'Grievance Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your grievance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Do you have proof? (Dropdown)
                DropdownButtonFormField<String>(
                  value: _hasProof,
                  decoration: const InputDecoration(
                    labelText: 'Do you have proof?',
                    border: OutlineInputBorder(),
                  ),
                  items: <String>['Yes', 'No'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _hasProof = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select if you have proof';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),

                // Information about proof
                const Text(
                  'Photos will not be considered as proof',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20.0),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _submitGrievance();
                        Navigator.pop(context, 'Grievance Submitted Successfully');
                      }
                    },
                    child: const Text('Submit'),
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