import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nuv2/screen/add.dart';


Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/products'));

  if (response.statusCode == 200) {
    try {
      final jsonResponse = jsonDecode(response.body);
      List<dynamic> productsJson = jsonResponse['data'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw FormatException('Failed to parse product JSON: $e');
    }
  } else {
    throw Exception('Failed to load products. Status code: ${response.statusCode}');
  }
}

Future<void> deleteAlbum(String id) async {
  final http.Response response = await http.delete(
    Uri.parse('http://10.0.2.2:8000/api/products/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete product.');
  }
}

Future<Product> updateAlbum(int id, String name, String des) async {
  try {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/products/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'des': des,
      }),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product.');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('An error occurred while updating product.');
  }
}

class Product {
  final int id;
  final String name;
  final String des;

  const Product({
    required this.id,
    required this.name,
    required this.des,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      des: json['des'] ?? '',
    );
  }
}

void main() => runApp(const HomePage());

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> futureProducts;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      futureProducts = fetchProducts();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fetch Data Example',
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 14, 79, 176),
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Todo List'),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (BuildContext context) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTodo(),
                  ),
                );
              },
              label: const Text(
                "Add",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: const Color.fromARGB(255, 102, 115, 102),
            );
          },
        ),
        body: Center(
          child: FutureBuilder<List<Product>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return Slidable(
                        startActionPane: ActionPane(
                          motion: StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                try {
                                  await deleteAlbum(product.id.toString());
                                  setState(() {
                                    futureProducts = fetchProducts();
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to delete product: $e')),
                                  );
                                }
                              },
                              icon: Icons.delete,
                              label: 'Delete',
                              backgroundColor: const Color.fromARGB(255, 115, 110, 110),
                            ),
                            SlidableAction(
                              onPressed: (context) async {
                                TextEditingController nameController =
                                    TextEditingController(text: product.name);
                                TextEditingController desController =
                                    TextEditingController(text: product.des);

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          TextField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                                labelText: 'Name'),
                                          ),
                                          TextField(
                                            controller: desController,
                                            decoration: InputDecoration(
                                                labelText: 'Description'),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Save'),
                                          onPressed: () async {
                                            try {
                                              await updateAlbum(
                                                  product.id,
                                                  nameController.text,
                                                  desController.text);
                                              setState(() {
                                                futureProducts =
                                                    fetchProducts();
                                              });
                                              Navigator.of(context).pop();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Failed to update product: $e'),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icons.edit,
                              label: 'Edit',
                              backgroundColor: Colors.blue,
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(product.des),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
