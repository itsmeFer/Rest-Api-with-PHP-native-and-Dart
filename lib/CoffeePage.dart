import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:uaski/search.dart';

class CoffeePage extends StatefulWidget {
  @override
  _CoffeePageState createState() => _CoffeePageState();
}

class _CoffeePageState extends State<CoffeePage> {
  final Dio dio = Dio();
  final String apiUrl = "http://192.168.1.6/tes/api.php";

  List<Map<String, dynamic>> coffeeData = [];
  List<String> coffeeTypes = [];

  TextEditingController jenisController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController pembelianController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCoffeeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee Data'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Search()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _getCoffeeData();
                },
                child: Text('Get Coffee Data'),
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: jenisController,
                label: 'Jenis',
                readOnly: true,
              ),
              SizedBox(height: 8),
              _buildTextFormField(
                controller: priceController,
                label: 'Price',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              _buildTextFormField(
                controller: pembelianController,
                label: 'Pembelian',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              _buildTextFormField(
                controller: totalController,
                label: 'Total',
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _calculateTotal();
                },
                child: Text('Calculate Total'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _insertCoffee();
                },
                child: Text('Insert Coffee'),
              ),
              SizedBox(height: 16),
              _buildDropdownButton(),
              SizedBox(height: 16),
              _buildCoffeeList(),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      readOnly: readOnly,
      keyboardType: keyboardType,
    );
  }

  // Fungsi untuk membuat DropdownButton
  Widget _buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: jenisController.text.isNotEmpty ? jenisController.text : null,
      items: ["Minuman", "Makanan"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          jenisController.text = newValue!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Select Coffee Type',
        border: OutlineInputBorder(),
      ),
    );
  }

  // Fungsi untuk membuat daftar kopi
  Widget _buildCoffeeList() {
    return Column(
      children: coffeeData.map((coffee) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('ID: ${coffee['id']}'),
            subtitle: Text('Jenis: ${coffee['jenis']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _editCoffee(coffee);
                  },
                  child: Text('Edit'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _deleteCoffee(coffee['id']);
                  },
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Fungsi untuk menghapus data kopi
  Future<void> _deleteCoffee(String id) async {
    try {
      Response response = await dio.delete(
        'http://192.168.1.6/tes/delete.php',
        queryParameters: {'id': id},
      );
      print(response.data);

      _getCoffeeData(); // Refresh data after deletion
    } catch (e) {
      print("Error deleting coffee: $e");
    }
  }

  // Fungsi untuk mengedit data kopi
  Future<void> _editCoffee(Map<String, dynamic> coffee) async {
    try {
      // Populate the text fields with the selected coffee data
      jenisController.text = coffee['jenis'];
      priceController.text = coffee['price'].toString();
      pembelianController.text = coffee['pembelian'].toString();
      totalController.text = coffee['total'].toString();

      // Show a dialog with edit controls
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Coffee'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextFormField(
                    controller: jenisController,
                    label: 'Jenis',
                  ),
                  _buildTextFormField(
                    controller: priceController,
                    label: 'Price',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextFormField(
                    controller: pembelianController,
                    label: 'Pembelian',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextFormField(
                    controller: totalController,
                    label: 'Total',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _calculateTotalEdit();
                    },
                    child: Text('Calculate Total'),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateCoffee(coffee['id'].toString());
                  Navigator.of(context)
                      .pop(); // Close the dialog after updating
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error editing coffee: $e");
    }
  }

  // Fungsi untuk menghitung total harga pembelian kopi yang diedit
  Future<void> _calculateTotalEdit() async {
    try {
      if (priceController.text.isEmpty || pembelianController.text.isEmpty) {
        _showAlertDialog("Alert", "Text boxes cannot be empty!");
        return;
      }

      int price = int.parse(priceController.text);
      int pembelian = int.parse(pembelianController.text);

      int total = price * pembelian;
      totalController.text = total.toString();
    } catch (e) {
      print("Error calculating total: $e");
    }
    return Future.value(); // Add this line to satisfy the return type
  }

  // Fungsi untuk mengupdate data kopi
  Future<void> _updateCoffee(String id) async {
    try {
      // Validate input
      if (jenisController.text.isEmpty ||
          priceController.text.isEmpty ||
          pembelianController.text.isEmpty ||
          totalController.text.isEmpty) {
        _showAlertDialog("Alert", "Text boxes cannot be empty!");
        return;
      }

      // Convert values to string
      String jenis = jenisController.text;
      String price = priceController.text;
      String pembelian = pembelianController.text;
      String total = totalController.text;

      // Create a map with updated coffee data
      Map<String, dynamic> updatedCoffee = {
        "id": id,
        "jenis": jenis,
        "price": int.parse(price),
        "pembelian": int.parse(pembelian),
        "total": int.parse(total),
      };

      // Perform the update request
      Response response =
          await dio.put('http://192.168.1.6/tes/api.php', data: updatedCoffee);
      print(response.data);

      // Clear the controllers and refresh data
      jenisController.clear();
      priceController.clear();
      pembelianController.clear();
      totalController.clear();
      _getCoffeeData();
    } catch (e) {
      print("Error updating coffee: $e");
    }
  }

  // Fungsi untuk menghitung total harga pembelian kopi
  Future<void> _calculateTotal() async {
    try {
      if (priceController.text.isEmpty || pembelianController.text.isEmpty) {
        _showAlertDialog("Alert", "Text boxes cannot be empty!");
        return;
      }

      int price = int.parse(priceController.text);
      int pembelian = int.parse(pembelianController.text);

      int total = price * pembelian;
      totalController.text = total.toString();
    } catch (e) {
      print("Error calculating total: $e");
    }
  }

  // Fungsi untuk menyisipkan data kopi baru
  Future<void> _insertCoffee() async {
    try {
      if (jenisController.text.isEmpty ||
          priceController.text.isEmpty ||
          pembelianController.text.isEmpty ||
          totalController.text.isEmpty) {
        _showAlertDialog("Alert", "Text boxes cannot be empty!");
        return;
      }

      Map<String, dynamic> coffeeData = {
        "jenis": jenisController.text,
        "price": int.parse(priceController.text),
        "pembelian": int.parse(pembelianController.text),
        "total": int.parse(totalController.text),
      };

      Response response = await dio.post(apiUrl, data: coffeeData);
      print(response.data);

      jenisController.clear();
      priceController.clear();
      pembelianController.clear();
      totalController.clear();

      _getCoffeeData();
    } catch (e) {
      print("Error inserting coffee: $e");
    }
  }

  // Fungsi untuk mendapatkan data kopi dari API
  Future<void> _getCoffeeData() async {
    try {
      Response response = await dio.get(apiUrl);
      setState(() {
        coffeeData = List<Map<String, dynamic>>.from(response.data);
        coffeeTypes =
            coffeeData.map((data) => data['jenis'] as String).toList();
      });
      print(coffeeData);
    } catch (e) {
      print("Error getting coffee data: $e");
    }
  }

  // Fungsi untuk menampilkan AlertDialog
  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CoffeePage(),
  ));
}
