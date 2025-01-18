import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rolebase/ManagementDashboard.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rolebase/history_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';


class TopStories extends StatefulWidget {
  const TopStories({Key? key}) : super(key: key);

  @override
  _TopStoriesState createState() => _TopStoriesState();
}

class _TopStoriesState extends State<TopStories> {
  FirebaseStorage storage = FirebaseStorage.instance;
  List<String> uploadedFiles = [];
  bool isLoading = false;
  final picker = ImagePicker();
  File? selectedFile;
  String fileUrl = '';
  final messageController = TextEditingController();
  final titleController = TextEditingController(); // Added title controller

  @override
  void initState() {
    super.initState();
    fetchFiles();
    // requestPermissions();
  }

  // Future<void> requestPermissions() async {
  //   await [Permission.storage].request();
  // }

  Future<void> fetchFiles() async {
    try {
      setState(() {
        isLoading = true;
      });

      ListResult result = await storage.ref('uploads/').listAll();

      setState(() {
        uploadedFiles.clear();
        for (Reference ref in result.items) {
          String fileName = ref.name;
          uploadedFiles.add(fileName);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching files: $e');
    }
  }

  Future<void> uploadFile() async {
    await pickImage();

    if (selectedFile != null) {
      String fileName = DateTime.now().toIso8601String();
      Reference storageReference = storage.ref().child('uploads/$fileName');
      UploadTask uploadTask = storageReference.putFile(selectedFile!);
      await uploadTask.whenComplete(() async {
        fileUrl = await storageReference.getDownloadURL();
        print('File uploaded, download URL: $fileUrl');
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> sendMessage() async {
    final message = messageController.text;
    final title = titleController.text; // Capture the title input

    if ((message.isNotEmpty || fileUrl.isNotEmpty) && title.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('stories').add({
          'title': title, // Upload the title
          'text': message.isNotEmpty ? message : null,
          'file': fileUrl.isNotEmpty ? fileUrl : null,
          'fileType': 'image',
          'timestamp': FieldValue.serverTimestamp(),
        });

        messageController.clear();
        titleController.clear(); // Clear the title input
        setState(() {
          fileUrl = '';
          selectedFile = null;
        });
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      print('Title is required, and either message or file must be present');
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown Date';
    }
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Stories'),
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stories')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }

                final docs = snapshot.data?.docs;
                Map<String, List<DocumentSnapshot>> groupedMessages = {};

                for (DocumentSnapshot doc in docs!) {
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['timestamp'] as Timestamp?;

                  if (timestamp == null) {
                    continue;
                  }

                  String formattedDate = formatDate(timestamp);

                  if (!groupedMessages.containsKey(formattedDate)) {
                    groupedMessages[formattedDate] = [];
                  }

                  groupedMessages[formattedDate]!.add(doc);
                }

                List<Widget> messageWidgets = [];
                groupedMessages.forEach((date, messages) {
                  messageWidgets.add(
                    Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = messages[index];
                            final data = doc.data() as Map<String, dynamic>;
                            String image = data['file'] ?? '';
                            String text = data['text'] ?? '';
                            String title = data['title'] ?? ''; // Retrieve title

                            return Card(
                              elevation: 3,
                              color: Colors.grey[200],
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (title.isNotEmpty) // Display title
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    if (image.isNotEmpty) // Display image
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FullScreenImage(
                                                imageUrl: image,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          image,
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(text),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                });

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(15.0),
          //   child: Column(
          //     children: [
          //       TextFormField(
          //         controller: titleController,
          //         decoration: const InputDecoration(
          //           labelText: 'Enter Title',
          //           border: OutlineInputBorder(),
          //         ),
          //       ),
          //       const SizedBox(height: 10),
          //       Row(
          //         children: [
          //           if (selectedFile != null)
          //             Stack(
          //               children: [
          //                 Container(
          //                   width: 50,
          //                   height: 50,
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(8),
          //                     image: DecorationImage(
          //                       image: FileImage(selectedFile!),
          //                       fit: BoxFit.cover,
          //                     ),
          //                   ),
          //                   margin: const EdgeInsets.only(right: 8),
          //                 ),
          //                 Positioned(
          //                   top: 0,
          //                   right: -5,
          //                   child: IconButton(
          //                     icon: const Icon(Icons.close, color: Colors.redAccent),
          //                     onPressed: () {
          //                       setState(() {
          //                         selectedFile = null;
          //                       });
          //                     },
          //                   ),
          //                 ),
          //               ],
          //             ),
                  //   Expanded(
                  //     child: TextFormField(
                  //       controller: messageController,
                  //       decoration: const InputDecoration(
                  //         labelText: 'Enter your message',
                  //         border: OutlineInputBorder(),
                  //       ),
                  //     ),
                  //   ),
                  //   IconButton(
                  //     onPressed: uploadFile,
                  //     icon: const Icon(Icons.attach_file),
                  //   ),
                  //   IconButton(
                  //     onPressed: sendMessage,
                  //     icon: const Icon(Icons.send),
                  //   ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
