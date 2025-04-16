import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nuv2/screen/home.dart';

bool isSuccess = false;

Future<Album> createAlbum(String name, String des) async {
  Album product = Album(id: 0, name: name, des: des);

  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/api/products'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(product.toMap()), 
  );

  if (response.statusCode == 201) {
    isSuccess = true;
    return Album.fromJson(jsonDecode(response.body));
  } else {
    isSuccess = false;
    throw Exception('Failed to add product');
  }
}

class Album {
  final int id;
  final String name;
  final String des;

  Album({
    required this.id,
    required this.name,
    required this.des,
  });

  // Factory method to create a Product from a Map (e.g., from JSON)
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      des: json['des'] ?? '',
    );
  }
//
  // Method to convert Product instance to a Map (e.g., to send as JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'des': des,
    };
  }
}

void main() {
  runApp(const AddTodo());
}

class AddTodo extends StatefulWidget {
  const AddTodo({super.key});

  @override
  State<AddTodo> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<AddTodo> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  Future<Album>? _futureAlbum;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Create Data Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Todo'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: (_futureAlbum == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter Title'),
        ),
        TextField(
          controller: _controller1,
          decoration: const InputDecoration(hintText: 'Enter des'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureAlbum = createAlbum(_controller.text, _controller1.text);
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
      future: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          if (isSuccess) {
            return const Text("you Created");
          } else {
            return const Text('you did not Created');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
