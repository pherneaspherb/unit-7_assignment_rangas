import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Function to fetch data from the Digi API
  Future<List<dynamic>> fetchDigimons() async {
    final response = await http.get(Uri.parse('https://digi-api.com/api/v1/digimon?pageSize=20'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData['content']; // content contains the list of digimons
    } else {
      throw Exception('Failed to load digimons'); // if failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digimon Explorer"), // the title
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchDigimons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Digimons found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final digimon = snapshot.data![index];
                final controller = ExpandedTileController();

                // own description, there is no description locatedd in the api 
                String description = "A powerful Digimon known as ${digimon['name']} with unique abilities.";

                return ExpandedTile(
                  controller: controller,
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          digimon['image'] ?? 'https://www.example.com/default_image.jpg',
                        ),
                        radius: 80,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              digimon['name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Level: ${digimon['level'] ?? 'Unknown Level'}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description, // all have the same description, since in the api, there are no any description located
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
