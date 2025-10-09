import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rolebase/aboutleague.dart';
import 'package:rolebase/Scoreboard.dart'; 
import 'package:rolebase/AnnaWarriorsScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'BlackEaglesScreen.dart';
import 'DefendingTitansScreen.dart';
import 'RetroRivalsScreen.dart';
import 'RisingGiantsScreen.dart';
import 'TheScoutRegimentScreen.dart';
import 'WhiteWalkersScreen.dart';
import 'management_info_screen.dart';
import 'EmergencyContact.dart';
import 'Captains.dart';
import 'Developers.dart';
import 'LoginPage.dart';
import 'Grivance.dart';
import 'stories.dart';
import 'package:rolebase/Photos.dart';
import 'package:rolebase/team_data_uploader.dart';

class ManagementLandingPage extends StatefulWidget {
  @override
  _ManagementLandingPageState createState() => _ManagementLandingPageState();
}

class _ManagementLandingPageState extends State<ManagementLandingPage> {
  int _currentIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  final List<Map<String, String>> cardData = [
    {'title': 'Black Eagles', 'logo': 'assets/logo1.png'},
    {'title': 'Anna Warriors', 'logo': 'assets/logo2.png'},
    {'title': 'Defending Titans', 'logo': 'assets/logo3.png'},
    {'title': 'White Walkers', 'logo': 'assets/logo4.png'},
    {'title': 'The Scout Regiment', 'logo': 'assets/logo5.png'},
    {'title': 'Retro Rivals', 'logo': 'assets/logo6.png'},
    {'title': 'Rising Giants', 'logo': 'assets/logo7.png'},
    {'title': 'Management Team', 'logo': 'assets/Management.png'},
  ];


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
    

  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < 6) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // Fetch photo URLs from Firestore
  Future<List<String>> _fetchPhotoUrls() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('gallery').doc('photos').get();
      List<String> photoUrls = [];

      // Assuming your photos are stored in fields pic1, pic2, pic3, ..., pic7
      for (int i = 1; i <= 10; i++) {
        String? url = snapshot.get('pic$i');
        if (url != null) {
          photoUrls.add(url);
        }
      }
      print('Fetched photo URLs: $photoUrls'); // Debug print
      return photoUrls;
    } catch (e) {
      throw Exception("Failed to fetch photos: $e");
    }
  }

  Future<void> openPDFInBrowser(String url) async {
    final Uri pdfUri = Uri.parse(url);  // Convert URL to Uri object

    // Open the link in an external browser (e.g., Chrome)
    if (!await launchUrl(pdfUri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open the PDF';
    }
  }

  Future<String?> fetchPDFLink() async {
  try {
    // Fetch the document from Firestore
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Rulebook')  // Replace with your collection name
        .doc('PDF')      // Replace with your document ID
        .get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Extract the 'link' field from the document
      String pdfLink = documentSnapshot['link'];  // Assuming the field is named 'link'
      return pdfLink;  // Return the PDF link
    } else {
      print('Document does not exist');
    }
  } catch (e) {
    print('Error fetching document: $e');
  }
  
  return null;  // Return null if there's an error or the document doesn't exist
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
        title: Row(
          children: [
            Text(
              'Hi Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.leaderboard_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScoreboardScreen()),
                );
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 180, 68),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  SizedBox(height: 10),
                  Text(
                    'TNPS Hostel League',
                    style: TextStyle(
                      color: const Color.fromARGB(249, 0, 0, 0),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

 
            _buildDrawerItem(context, Icons.menu_book, 'RuleBook', () async {
              String? pdfLink = await fetchPDFLink();

              if (pdfLink != null) {
                try {
                  await openPDFInBrowser(pdfLink);  // Open PDF link in external browser (Chrome)
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to open the PDF in browser'))
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load PDF link'))
                );
              }
            }),
            _buildDrawerItem(context, Icons.memory_outlined, 'Top Stories', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TopStories()));
            }),
            _buildDrawerItem(context, Icons.book_outlined, 'About League', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => About()));
            }),
            _buildDrawerItem(context, Icons.quick_contacts_dialer_rounded, 'Captains', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CaptainScreen()));
            }),
            _buildDrawerItem(context, Icons.call_outlined, 'Emergency Contacts', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyContactScreen()));
            }),
            _buildDrawerItem(context, Icons.stay_current_portrait_rounded, 'Developers', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DevelopersScreen()));
            }),
            _buildDrawerItem(context, Icons.rate_review_sharp, 'Grievance', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManagementGrievanceScreen()));
            }),
            _buildDrawerItem(context, Icons.image_outlined, 'Photos', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryScreen()));
            }),
            _buildDrawerItem(context, Icons.upload, 'Upload All CSV Data', () async {
              try {
                await TeamDataUploader.uploadAllTeamDataFromCSV();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All team data from CSV files uploaded successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error uploading CSV data: $e')),
                );
              }
            }),
            _buildDrawerItem(context, Icons.group, 'Upload Individual Teams', () {
              _showTeamUploadDialog(context);
            }),
            _buildDrawerItem(context, Icons.logout_rounded, 'Logout', () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
            }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<String>>(
              future: _fetchPhotoUrls(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No photos available'));
                }

                List<String> photoUrls = snapshot.data!;

                return Container(
                  height: 300.0, // Adjust height to cover the space of two cards
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: photoUrls.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: photoUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      );
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 16.0), // Spacer to separate the slider and the cards

            Padding(
              padding: EdgeInsets.all(10.0),
                child: GridView.builder(
                  shrinkWrap: true, 
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: cardData.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        switch (cardData[index]['title']) {
                          case 'Black Eagles':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BlackEaglesScreen()),
                            );
                            break;
                          case 'Anna Warriors':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AnnaWarriorsScreen()),
                            );
                            break;
                          case 'Defending Titans':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DefendingTitansScreen()),
                            );
                            break;
                          case 'White Walkers':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WhiteWalkersScreen()),
                            );
                            break;
                          case 'The Scout Regiment':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TheScoutRegimentScreen()),
                            );
                            break;
                          case 'Retro Rivals':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RetroRivalsScreen()),
                            );
                            break;
                          case 'Rising Giants':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RisingGiantsScreen()),
                            );
                            break;
                          case 'Management Team':
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ManagementInfoScreen()),
                            );
                            break;
                          default:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CardScreen(cardData[index]['title'] ?? 'Unknown Card')),
                            );      
                            break;
                        }
                      },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              cardData[index]['logo'] ?? 'assets/default_logo.png',
                              height: 65,
                              width: 65,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image_not_supported);
                              },
                            ),
                            SizedBox(height: 8),
                            Text(
                              cardData[index]['title'] ?? 'Unknown Title',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create drawer items
  ListTile _buildDrawerItem(BuildContext context, IconData icon, String title, Function onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onTap(),
    );
  }

  // Show dialog for individual team uploads
  void _showTeamUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Team Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select a team to upload CSV data:'),
              SizedBox(height: 20),
              _buildTeamUploadButton(context, 'The Scout Regiment', 'scout regiment.csv'),
              _buildTeamUploadButton(context, 'White Walkers', 'white walker.csv'),
              _buildTeamUploadButton(context, 'Rising Giants', 'rising giants.csv'),
              _buildTeamUploadButton(context, 'Anna Warriors', 'anna.csv'),
              _buildTeamUploadButton(context, 'Black Eagles', 'black_eagles.csv'),
              _buildTeamUploadButton(context, 'Defending Titans', 'defending.csv'),
              _buildTeamUploadButton(context, 'Retro Rivals', 'Retro_main.csv'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Build team upload button
  Widget _buildTeamUploadButton(BuildContext context, String teamName, String csvFile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () async {
          Navigator.of(context).pop();
          try {
            await TeamDataUploader.uploadTeamData(teamName);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$teamName data uploaded successfully!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error uploading $teamName data: $e')),
            );
          }
        },
        child: Text(teamName),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 180, 68),
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

class CardScreen extends StatelessWidget {
  final String title;
  CardScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
        title: Text(title),
      ),
      body: Center(
        child: Text('Details for $title will be shown here'),
      ),
    );
  }
}
