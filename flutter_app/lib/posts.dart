import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required Text title});

  @override
  State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<Posts> {
  String? _token;
  int _counter = 0;
  Map<String, dynamic>? _posts;

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    //
    final response = await http.get(Uri(
      host: '192.168.131.28',
      scheme: 'http',
      port: 8000,
      path: '/api/posts',
    ));

    if (response.statusCode == 500) {
      return;
    }

    setState(() {
      _token = token;
      _posts = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: '/pages',
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                getData();
                SharedPreferences.getInstance().then((value) {
                  setState(() {
                    _token = value.getString('token');
                  });
                  debugPrint(value.getString('token'));
                });
                setState(() {
                  _counter++;
                });
              },
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Color.fromRGBO(230, 138, 0, 1))),
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.black),
              ),
            ),
            Text(_token.toString()),
            Text(_counter.toString()),
          ],
        ),
      ),
    );
  }
}

class PostsPage extends StatelessWidget {
  const PostsPage({Key? key, required Text title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Posts LAh',
      home: Posts(title: Text("asd")),
    );
  }
}
