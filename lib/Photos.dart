import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryScreen extends StatelessWidget {
  // Fetch data from Firestore with error handling
  Future<List<String>> _fetchPhotoUrls() async {
    try {
      // Get the 'photos' document from the 'gallery' collection
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('gallery')
          .doc('photos')
          .get();

      // Check if the document exists
      if (snapshot.exists) {
        // Extract URLs from fields like pic1, pic2, etc.
        List<String> photoUrls = [];

        // Loop through a known number of fields (in this case, 7 photos)
        for (int i = 1; i <= 10; i++) {
          // Access each field dynamically as 'pic1', 'pic2', etc.
          String? url = snapshot.get('pic$i') as String?;
          if (url != null) {
            photoUrls.add(url);
          }
        }
        return photoUrls;
      } else {
        // If the document doesn't exist, return an empty list
        return [];
      }
    } catch (e) {
      // Catch any errors and print/log them
      print('Error fetching photos: $e');
      throw Exception('Error fetching photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
         backgroundColor:  const Color.fromARGB(255, 255, 180, 68),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchPhotoUrls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display the error message in the UI
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No photos available'));
          }

          // List of photo URLs
          List<String> photoUrls = snapshot.data!;

          // Display photos in a scrollable ListView
          return ListView.builder(
            itemCount: photoUrls.length,
            itemBuilder: (context, index) {
              return _buildPhotoItem(context, photoUrls[index]);
            },
          );
        },
      ),
    );
  }

  // Widget to build each photo item
  Widget _buildPhotoItem(BuildContext context, String url) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
