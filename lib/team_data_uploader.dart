import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class TeamDataUploader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload data for The Scout Regiment from CSV
  static Future<void> uploadScoutRegimentData() async {
    try {
      // Read CSV data
      String csvData = await rootBundle.loadString('assets/scout regiment.csv');
      List<String> lines = csvData.split('\n');
      
      List<Map<String, dynamic>> scoutRegimentMembers = [];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
            String name = parts[1].trim();
            scoutRegimentMembers.add({
              'name': name,
              'phone_number': '0000000000', // Placeholder - can be updated later
              'room_number': 'TBD', // To be determined
              'year': 'TBD', // To be determined
              'cultural_activity': 'TBD', // To be determined
              'sports': [], // Empty - can be filled later
              'player_status': 'false',
              'team_name': 'The Scout Regiment',
            });
          }
        }
      }

      // Clear existing data and upload new data
      QuerySnapshot existingDocs = await _firestore.collection('The Scout Regiment').get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var member in scoutRegimentMembers) {
        await _firestore.collection('The Scout Regiment').add(member);
      }
      
      print('Scout Regiment data uploaded successfully! ${scoutRegimentMembers.length} members added.');
    } catch (e) {
      print('Error uploading Scout Regiment data: $e');
    }
  }

  // Upload data for White Walkers from CSV
  static Future<void> uploadWhiteWalkersData() async {
    try {
      // Read CSV data
      String csvData = await rootBundle.loadString('assets/white walker.csv');
      List<String> lines = csvData.split('\n');
      
      List<Map<String, dynamic>> whiteWalkersMembers = [];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
            String name = parts[1].trim();
            whiteWalkersMembers.add({
              'name': name,
              'phone_number': '0000000000', // Placeholder - can be updated later
              'room_number': 'TBD', // To be determined
              'year': 'TBD', // To be determined
              'cultural_activity': 'TBD', // To be determined
              'sports': [], // Empty - can be filled later
              'player_status': 'false',
              'team_name': 'White Walkers',
            });
          }
        }
      }

      // Clear existing data and upload new data
      QuerySnapshot existingDocs = await _firestore.collection('White Walkers').get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var member in whiteWalkersMembers) {
        await _firestore.collection('White Walkers').add(member);
      }
      
      print('White Walkers data uploaded successfully! ${whiteWalkersMembers.length} members added.');
    } catch (e) {
      print('Error uploading White Walkers data: $e');
    }
  }

  // Upload data for Rising Giants from CSV
  static Future<void> uploadRisingGiantsData() async {
    try {
      // Read CSV data
      String csvData = await rootBundle.loadString('assets/rising giants.csv');
      List<String> lines = csvData.split('\n');
      
      List<Map<String, dynamic>> risingGiantsMembers = [];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
            String name = parts[1].trim();
            risingGiantsMembers.add({
              'name': name,
              'phone_number': '0000000000', // Placeholder - can be updated later
              'room_number': 'TBD', // To be determined
              'year': 'TBD', // To be determined
              'cultural_activity': 'TBD', // To be determined
              'sports': [], // Empty - can be filled later
              'player_status': 'false',
              'team_name': 'Rising Giants',
            });
          }
        }
      }

      // Clear existing data and upload new data
      QuerySnapshot existingDocs = await _firestore.collection('Rising Giants').get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var member in risingGiantsMembers) {
        await _firestore.collection('Rising Giants').add(member);
      }
      
      print('Rising Giants data uploaded successfully! ${risingGiantsMembers.length} members added.');
    } catch (e) {
      print('Error uploading Rising Giants data: $e');
    }
  }

  // Upload data for Anna Warriors from CSV
  static Future<void> uploadAnnaWarriorsData() async {
    try {
      // Read CSV data
      String csvData = await rootBundle.loadString('assets/anna.csv');
      List<String> lines = csvData.split('\n');
      
      List<Map<String, dynamic>> annaWarriorsMembers = [];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
            String name = parts[1].trim();
            annaWarriorsMembers.add({
              'name': name,
              'phone_number': '0000000000', // Placeholder - can be updated later
              'room_number': 'TBD', // To be determined
              'year': 'TBD', // To be determined
              'cultural_activity': 'TBD', // To be determined
              'sports': [], // Empty - can be filled later
              'player_status': 'false',
              'team_name': 'Anna Warriors',
            });
          }
        }
      }

      // Clear existing data and upload new data
      QuerySnapshot existingDocs = await _firestore.collection('Anna Warriors').get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var member in annaWarriorsMembers) {
        await _firestore.collection('Anna Warriors').add(member);
      }
      
      print('Anna Warriors data uploaded successfully! ${annaWarriorsMembers.length} members added.');
    } catch (e) {
      print('Error uploading Anna Warriors data: $e');
    }
  }

  // Upload data for Black Eagles from CSV
  static Future<void> uploadBlackEaglesData() async {
    try {
      // Read CSV data
      String csvData = await rootBundle.loadString('assets/black_eagles.csv');
      List<String> lines = csvData.split('\n');
      
      List<Map<String, dynamic>> blackEaglesMembers = [];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
            String name = parts[1].trim();
            blackEaglesMembers.add({
              'name': name,
              'phone_number': '0000000000', // Placeholder - can be updated later
              'room_number': 'TBD', // To be determined
              'year': 'TBD', // To be determined
              'cultural_activity': 'TBD', // To be determined
              'sports': [], // Empty - can be filled later
              'player_status': 'false',
              'team_name': 'Black Eagles',
            });
          }
        }
      }

      // Clear existing data and upload new data
      QuerySnapshot existingDocs = await _firestore.collection('Black Eagles').get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var member in blackEaglesMembers) {
        await _firestore.collection('Black Eagles').add(member);
      }
      
      print('Black Eagles data uploaded successfully! ${blackEaglesMembers.length} members added.');
    } catch (e) {
      print('Error uploading Black Eagles data: $e');
    }
  }

  // Upload data for Defending Titans from CSV
  static Future<void> uploadDefendingTitansData() async {
    try {
      // Read CSV data
      String csvData = await rootBundle.loadString('assets/defending.csv');
      List<String> lines = csvData.split('\n');
      
      List<Map<String, dynamic>> defendingTitansMembers = [];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
            String name = parts[1].trim();
            defendingTitansMembers.add({
              'name': name,
              'phone_number': '0000000000', // Placeholder - can be updated later
              'room_number': 'TBD', // To be determined
              'year': 'TBD', // To be determined
              'cultural_activity': 'TBD', // To be determined
              'sports': [], // Empty - can be filled later
              'player_status': 'false',
              'team_name': 'Defending Titans',
            });
          }
        }
      }

      // Clear existing data and upload new data
      QuerySnapshot existingDocs = await _firestore.collection('Defending Titans').get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var member in defendingTitansMembers) {
        await _firestore.collection('Defending Titans').add(member);
      }
      
      print('Defending Titans data uploaded successfully! ${defendingTitansMembers.length} members added.');
    } catch (e) {
      print('Error uploading Defending Titans data: $e');
    }
  }

  // Upload data for Retro Rivals from CSV
  static Future<void> uploadRetroRivalsData() async {
    try {
      // Read CSV data
      String csvData = await rootBundle.loadString('assets/Retro_main.csv');
      List<String> lines = csvData.split('\n');
      
      List<Map<String, dynamic>> retroRivalsMembers = [];
      
      for (int i = 1; i < lines.length; i++) { // Skip header
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.length >= 2 && parts[1].trim().isNotEmpty) { // Retro Rivals CSV has name at index 1
            String name = parts[1].trim();
            retroRivalsMembers.add({
              'name': name,
              'phone_number': '0000000000', // Placeholder - can be updated later
              'room_number': 'TBD', // To be determined
              'year': 'TBD', // To be determined
              'cultural_activity': 'TBD', // To be determined
              'sports': [], // Empty - can be filled later
              'player_status': 'false',
              'team_name': 'Retro Rivals',
            });
          }
        }
      }

      // Clear existing data and upload new data
      QuerySnapshot existingDocs = await _firestore.collection('Retro Rivals').get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var member in retroRivalsMembers) {
        await _firestore.collection('Retro Rivals').add(member);
      }
      
      print('Retro Rivals data uploaded successfully! ${retroRivalsMembers.length} members added.');
    } catch (e) {
      print('Error uploading Retro Rivals data: $e');
    }
  }

  // Upload all team data from CSV files
  static Future<void> uploadAllTeamDataFromCSV() async {
    await uploadScoutRegimentData();
    await uploadWhiteWalkersData();
    await uploadRisingGiantsData();
    await uploadAnnaWarriorsData();
    await uploadBlackEaglesData();
    await uploadDefendingTitansData();
    await uploadRetroRivalsData();
    print('All team data from CSV files uploaded successfully!');
  }

  // Upload specific team data
  static Future<void> uploadTeamData(String teamName) async {
    switch (teamName.toLowerCase()) {
      case 'the scout regiment':
        await uploadScoutRegimentData();
        break;
      case 'white walkers':
        await uploadWhiteWalkersData();
        break;
      case 'rising giants':
        await uploadRisingGiantsData();
        break;
      case 'anna warriors':
        await uploadAnnaWarriorsData();
        break;
      case 'black eagles':
        await uploadBlackEaglesData();
        break;
      case 'defending titans':
        await uploadDefendingTitansData();
        break;
      case 'retro rivals':
        await uploadRetroRivalsData();
        break;
      default:
        print('Unknown team: $teamName');
    }
  }
}
