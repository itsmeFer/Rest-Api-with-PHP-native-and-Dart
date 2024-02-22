import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final Dio dio = Dio();
  final String apiUrl = "http://192.168.1.6/tes/api.php";

  List<Map<String, dynamic>> coffeeData = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCoffeeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Data'),
        actions: [
          // Add a cancel button to go back to CoffeePage
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Go back to the previous screen
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Add this to your CoffeePageState class
              TextField(
                onChanged: (value) {
                  _searchCoffeeData(value);
                },
                decoration: InputDecoration(labelText: 'Search'),
              ),

              SizedBox(height: 16),
              // Display coffee data in a widget
              ListView.builder(
                shrinkWrap: true,
                itemCount: coffeeData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${index + 1}. ID: ${coffeeData[index]['id']}',
                    ),
                    subtitle: Text('Jenis: ${coffeeData[index]['jenis']}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update this method in your CoffeePageState class
  Future<void> _searchCoffeeData(String keyword) async {
    try {
      // Search by ID or 'jenis' based on input
      Response response = await dio.get('$apiUrl?search=$keyword');
      setState(() {
        coffeeData = List<Map<String, dynamic>>.from(response.data);
      });
      print(coffeeData);
    } catch (e) {
      print("Error searching coffee data: $e");
    }
  }

  Future<void> _getCoffeeData() async {
    try {
      Response response = await dio.get(apiUrl);
      setState(() {
        coffeeData = List<Map<String, dynamic>>.from(response.data);
      });
      print(coffeeData);
    } catch (e) {
      print("Error getting coffee data: $e");
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Search(),
  ));
}
