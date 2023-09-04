import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/nav_bar.dart';
import 'package:flutter_app/post_card.dart';
import 'package:flutter_app/post_create.dart';
import 'package:flutter_app/profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required Text title});

  @override
  PostsState createState() => PostsState();
  // State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<Posts> {
  // String? _token;
  int _pageIndex = 0;
  List<dynamic>? _posts = [];

  Future<List<dynamic>> getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    //
    final response = await http.get(
        Uri(
          host: '192.168.131.28',
          scheme: 'http',
          port: 8000,
          path: '/api/posts',
        ),
        headers: {'Authorization': 'Bearer $token'});
    debugPrint(response.body);

    if (response.statusCode == 500) {
      return [];
    }

    setState(() {
      // _token = token;
      _posts = jsonDecode(response.body);
    });

    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(jsonEncode(_posts));
    return MaterialApp(
      theme: ThemeData(
        cardTheme: const CardTheme(
          shadowColor: Color(0xFFFF8C00),
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 20.0,
            // color: Colors.black,
          ),
        ),
        appBarTheme:
            const AppBarTheme(backgroundColor: Color.fromRGBO(230, 138, 0, 1)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: [
            const Text('Post in Aja'),
            const Text('New Post'),
            const Text('Profile'),
          ][_pageIndex],
        ),
        bottomNavigationBar: NavBar(
          setPageIndex: (index) {
            setState(() {
              _pageIndex = index;
            });
          },
        ),
        body: [
          RefreshIndicator(
            onRefresh: () async {
              var data = await getData();
              setState(() {
                _posts = [];
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                setState(() {
                  _posts = data;
                });
              });
            },
            child: LayoutBuilder(
              builder: (context, constrain) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constrain.maxHeight),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var post in _posts!)
                          PostCard(
                            post: post,
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const PostCreate(),
          const Profile()
        ][_pageIndex],
      ),
    );
  }
}

// class PostsPage extends StatelessWidget {
//   const PostsPage({Key? key, required Text title}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Posts LAh',
//       home: Posts(title: Text("asd")),
//     );
//   }
// }
