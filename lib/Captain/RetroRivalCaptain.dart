import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';

class RetroRivalsCaptain extends StatefulWidget {
  final String teamName = 'Retro Rivals';

  @override
  _RetroRivalsCaptainState createState() => _RetroRivalsCaptainState();
}

class _RetroRivalsCaptainState extends State<RetroRivalsCaptain> {
  List<List<dynamic>> _players = [];

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    print('Fetching players for Retro Rivals...'); // Debug print
    try {
      final String csvString = await rootBundle.loadString('assets/Retro_main.csv');
      print('CSV String: $csvString'); // Debug print
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);
      print('CSV Table: $csvTable'); // Debug print
      setState(() {
        _players = csvTable.sublist(1); // Skip the header row
        print('Players after setState: $_players'); // Debug print
      });
    } catch (e) {
      print('Error fetching players from CSV: $e');
      // Handle error, maybe show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
        title: Text(widget.teamName),
      ),
      body: _players.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final playerDoc = _players[index];
                final name = playerDoc[1] ?? 'Unnamed';
                final sports = List<String>.from(playerDoc.length > 2 ? playerDoc.sublist(2) : []);

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
                          if (false) // Always false since player_status is not in CSV
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
                                sport.toString(), // Convert to string
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    final playerData = {
                      'name': playerDoc[1],
                      'team_name': widget.teamName,
                      'sports': sports,
                      'player_status': false, // Default to false as it's not in CSV
                    };
                    if (playerData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerDetailsScreen(playerData: playerData as Map<String, dynamic>),
                        ),
                      );
                    } else {
                      // Handle case where player data is null (e.g., show a snackbar)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Player data is empty.'))
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}

class PlayerDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> playerData;

  PlayerDetailsScreen({required this.playerData});

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
    final name = playerData['name'] ?? 'N/A';
    final sports = List<String>.from(playerData['sports'] ?? []);
    final teamName = playerData['team_name'] ?? 'N/A';
    final playerStatus = playerData['player_status'] ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 180, 68),
        title: Text('Player Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailCard('Name', name),
            _buildDetailCard('Team', teamName),
            _buildDetailCard('Sports', sports.join(', ')),
            _buildDetailCard('Status', playerStatus ? 'Blocked' : 'Active'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
