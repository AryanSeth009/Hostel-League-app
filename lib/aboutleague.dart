import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



// Upload 
/*
class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  // Define a global key for the form
  final _formKey = GlobalKey<FormState>();

  // Controllers to get input from the fields
  final TextEditingController _aboutLeagueController = TextEditingController();
  final TextEditingController _fathersMessageController = TextEditingController();
  final TextEditingController _wardensMessageController = TextEditingController();

  // Function to save the form data to Firestore
  Future<void> _saveFormData() async {
    if (_formKey.currentState!.validate()) {
      // Access the Firestore collection and add the data
      await FirebaseFirestore.instance.collection('league_info').add({
        'about_league': _aboutLeagueController.text,
        'fathers_message': _fathersMessageController.text,
        'wardens_message': _wardensMessageController.text,
      });

      // Clear the form fields after submission
      _aboutLeagueController.clear();
      _fathersMessageController.clear();
      _wardensMessageController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit League Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Attach the form key
          child: ListView(
            children: <Widget>[
              // About League field
              TextFormField(
                controller: _aboutLeagueController,
                decoration: InputDecoration(labelText: 'About League'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter information about the league';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Father's Message field
              TextFormField(
                controller: _fathersMessageController,
                decoration: InputDecoration(labelText: "Father's Message"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Father\'s message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Warden's Message field
              TextFormField(
                controller: _wardensMessageController,
                decoration: InputDecoration(labelText: "Warden's Message"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Warden\'s message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: _saveFormData, // Call the function on submit
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _aboutLeagueController.dispose();
    _fathersMessageController.dispose();
    _wardensMessageController.dispose();
    super.dispose();
  }
}
*/




class About extends StatefulWidget {
  @override
  __AboutStateState createState() => __AboutStateState();
}

class __AboutStateState extends State<About> {
  // Function to fetch data from Firestore
  Stream<QuerySnapshot> _fetchData() {
    return FirebaseFirestore.instance.collection('league_info').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
        title: Text('League Information'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchData(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Error Handling
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Show loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // If data is available, display it
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final data = snapshot.data!.docs;

            return ListView.builder(
              itemCount: data.length * 3, // Multiply by 3 to account for 3 fields per record
              itemBuilder: (context, index) {
                var leagueData = data[index ~/ 3]; // Divide index by 3 to get correct record
            
                // Extract data from Firestore fields
                String aboutLeague = leagueData['about_league'] ?? 'No data';
                String fathersMessage = leagueData['fathers_message'] ?? 'No data';
                String wardensMessage = leagueData['wardens_message'] ?? 'No data';
                String fathersImage = leagueData['Fathers_image'] ?? ''; // Get Father's Image URL
                String wardensImage = leagueData['wardens_image'] ?? ''; // Get Warden's Image URL
                String fatherName = leagueData['fathers_name'] ?? 'Father'; // Father's name
                String wardenName = leagueData['wardens_name'] ?? 'Warden'; // Warden's name
            
                // Display each field in its own separate tile
                if (index % 3 == 0) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    elevation: 4, // Add elevation to give a shadow effect
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About League',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10), // Add spacing between title and content
                          Text(
                            aboutLeague,
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.black54, 
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify, // Correctly added textAlign to Text widget
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (index % 3 == 1) {
                  // Father's Message with larger Image on top and name below image
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // Center content
                        children: [
                          fathersImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10), // Rounded image
                                  child: Image.network(
                                    fathersImage,
                                    width: double.infinity, // Take full width of card
                                    height: 300, // Increased height
                                    fit: BoxFit.cover, // Cover entire image area
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error, size: 50); // Larger error icon
                                    },
                                  ),
                                )
                              : SizedBox.shrink(), // No image placeholder
                          SizedBox(height: 10), // Space between image and name
                          Text(
                            fatherName, // Display Father's name
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '(Asst. Financial Administrator & Hostel Manager)', 
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify, // Align custom text properly
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Father\'s Message',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            fathersMessage, // This will display the father's message
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.black54, 
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify, // Align the message text properly
                          ),
                          SizedBox(height: 10), // Space between name and title
                        ],
                      ),
                    ),
                  );
                } else {
                  // Warden's Message with larger Image on top and name below image
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // Center content
                        children: [
                          wardensImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10), // Rounded image
                                  child: Image.network(
                                    wardensImage,
                                    width: double.infinity, // Take full width of card
                                    height: 300, // Increased height
                                    fit: BoxFit.cover, // Cover entire image area
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error, size: 50); // Larger error icon
                                    },
                                  ),
                                )
                              : SizedBox.shrink(), // No image placeholder
                          SizedBox(height: 10), // Space between image and name
                          Text(
                            wardenName, // Display Warden's name
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10), // Space between name and title
                          Text(
                            'Warden\'s Message',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            wardensMessage,
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.black54, 
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify, // Correctly added textAlign to Text widget
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );

          }
          return Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }
}
