import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class WhiteWalkersScreen extends StatelessWidget {
  final String teamName = 'White Walkers'; // Automatically set team name

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
                onLongPress: () async {
                  // Determine the current player status
                  bool isBlocked = doc['player_status'] == "true";

                  // Show a confirmation dialog based on the current status
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(isBlocked ? "Unblock Player" : "Block Player"),
                        content: Text(isBlocked
                            ? "Do you want to unblock this player?"
                            : "Do you want to block this player?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // User pressed 'No'
                            },
                            child: Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // User pressed 'Yes'
                            },
                            child: Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );

                  // If user confirmed blocking/unblocking, update the player_status
                  if (confirm == true) {
                    try {
                      await FirebaseFirestore.instance
                          .collection(teamName)
                          .doc(documentId)
                          .update({'player_status': isBlocked ? "false" : "true"}); // Toggle the status

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isBlocked ? 'Player has been unblocked.' : 'Player has been blocked.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update player status: $e')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return AddMemberFormScreen(teamName: teamName);
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
      ),
    );
  }
}



class AddMemberFormScreen extends StatefulWidget {
  final String teamName; // Receive the team name as a parameter

  AddMemberFormScreen({required this.teamName});

  @override
  _AddMemberFormScreenState createState() => _AddMemberFormScreenState();
}

class _AddMemberFormScreenState extends State<AddMemberFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String name = '';
  String phoneNumber = '';
  String roomNumber = '';
  String? selectedYear;
  String? selectedCulturalActivity;
  List<String?> selectedSports = [null, null, null]; // List for 3 sports
  List<bool> sportLocked = [false, false, false]; // Track whether the sport is locked


  final List<String> yearOptions = ['1st', '2nd', '3rd', '4th'];
  final List<String> culturalOptions = ['Yes', 'No'];
  final List<String> sportsOptions = [
    'Cricket',
    'Football',
    'Basketball',
    'Volleyball',
    'Tug of War',
    'Badminton',
    'Table Tennis'
  ];

  Future<void> _showConfirmationDialog(int index, String selectedSport) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Sport'),
        content: Text('Do you want to lock **$selectedSport** as your Sport ${index + 1}?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              setState(() {
                // Reset the sport for this index to null
                selectedSports[index] = null;
                sportLocked[index] = false; // Unlock the dropdown
              });
              Navigator.of(context).pop(); // Close dialog
            },
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              setState(() {
                sportLocked[index] = true; // Lock the sport
                selectedSports[index] = selectedSport; // Update the sport
              });
              Navigator.of(context).pop(); // Close dialog
            },
          ),
        ],
      );
    },
  );
}




  // Function to check if a sport is already selected in other dropdowns
  bool _isSportAlreadySelected(String sport) {
  return selectedSports.contains(sport);
}

  Future<void> _submitData() async {
  try {
    final uniqueSports = selectedSports.where((sport) => sport != null).toSet().toList();
    await FirebaseFirestore.instance.collection(widget.teamName).add({
      'team_name': widget.teamName,
      'name': name,
      'phone_number': phoneNumber,
      'room_number': roomNumber,
      'year': selectedYear,
      'cultural_activity': selectedCulturalActivity,
      'sports': uniqueSports, // Store only unique sports
      'player_status': false, 
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data successfully added to Firebase!')),
    );
    Navigator.of(context).pop(); // Close the form after submission
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add data: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Add Team Member'),
            backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: widget.teamName,
                    decoration: InputDecoration(
                      labelText: 'Team Name',
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value ?? '';
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phoneNumber = value ?? '';
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Room Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a room number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      roomNumber = value ?? '';
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Year'),
                    value: selectedYear,
                    items: yearOptions.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a year';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      selectedYear = value ?? '';
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Cultural Activity'),
                    value: selectedCulturalActivity,
                    items: culturalOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCulturalActivity = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a cultural activity';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      selectedCulturalActivity = value ?? '';
                    },
                  ),
                  SizedBox(height: 16),
                  ...List.generate(3, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Sport ${index + 1}'),
                          value: selectedSports[index],
                          items: sportsOptions.map((String sport) {
                            return DropdownMenuItem<String>(
                              value: sport,
                              child: Text(sport),
                            );
                          }).toList(),
                          onChanged: sportLocked[index]
                              ? null
                              : (newValue) async {
                                  if (newValue != null) {
                                    if (_isSportAlreadySelected(newValue)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('This sport is already selected. Please choose a different one.')),
                                      );
                                    } else {
                                      await _showConfirmationDialog(index, newValue);
                                      if (sportLocked[index]) {
                                        setState(() {
                                          selectedSports[index] = newValue;
                                        });
                                      }
                                    }
                                  }
                                },
                          validator: (value) {
                            // Allow null values, no mandatory field check
                            return null;
                          },
                          onSaved: (value) {
                            selectedSports[index] = value;
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          await _submitData();
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        title: Text('Member Details'),
        backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('White Walkers')
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