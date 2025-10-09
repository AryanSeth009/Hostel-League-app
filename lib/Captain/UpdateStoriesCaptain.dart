import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UpdateStoriesCaptain extends StatefulWidget {
  const UpdateStoriesCaptain({Key? key}) : super(key: key);

  @override
  _UpdateStoriesCaptainState createState() => _UpdateStoriesCaptainState();
}

class _UpdateStoriesCaptainState extends State<UpdateStoriesCaptain> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  File? selectedFile;
  String fileUrl = '';
  final messageController = TextEditingController();
  final titleController = TextEditingController();
  bool _isLoading = false;

  Future<void> uploadFile() async {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
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
    final title = titleController.text;

    if ((message.isNotEmpty || fileUrl.isNotEmpty) && title.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('stories').add({
          'title': title,
          'text': message.isNotEmpty ? message : null,
          'file': fileUrl.isNotEmpty ? fileUrl : null,
          'fileType': 'image',
          'timestamp': FieldValue.serverTimestamp(),
        });

        messageController.clear();
        titleController.clear();
        setState(() {
          fileUrl = '';
          selectedFile = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Story uploaded successfully!')),
        );
      } catch (e) {
        print('Error sending message: $e');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading story: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title is required, and either message or file must be present')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Top Stories'),
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Enter Story Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextFormField(
                controller: messageController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Enter your message (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedFile != null)
                  Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(selectedFile!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      Positioned(
                        top: 0,
                        right: -5,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              selectedFile = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  onPressed: uploadFile,
                  icon: const Icon(Icons.attach_file),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : sendMessage,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20, // Adjust size as needed
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white), // Smaller spinner
                        )
                      : const Icon(Icons.send),
                  label: _isLoading ? const Text('Uploading...') : const Text('Send Story'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
