import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/post_card.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required Text title});

  @override
  PostsState createState() => PostsState();
  // State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<Posts> {
  String? _token;
  int _counter = 0;
  List<dynamic>? _posts = [];

  Future<void> getData() async {
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
    // debugPrint(jsonEncode(_posts));
    return MaterialApp(
      theme: ThemeData(
          cardTheme:
              const CardTheme(shadowColor: Color.fromRGBO(230, 138, 0, 1)),
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 20.0))),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Post in Aja'),
          backgroundColor: const Color.fromRGBO(230, 138, 0, 1),
        ),
        body: LayoutBuilder(
          builder: (context, constrain) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constrain.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var post in _posts!)
                      PostCard(
                        post: post,
                      )
                    // Card(
                    //   child: SizedBox(
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             post['author'],
                    //             style: const TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //           Text(
                    //             DateFormat('dd/MM/y').format(
                    //                 DateTime.parse(post['published_date'])),
                    //             textScaleFactor: 0.6,
                    //             style:
                    //                 const TextStyle(color: Color(0xFF8B8B8B)),
                    //           ),
                    //           Text(
                    //             post['title'],
                    //             style: const TextStyle(
                    //                 fontWeight: FontWeight.bold),
                    //           ),
                    //           Text(post['content'],
                    //               textScaleFactor: 0.6,
                    //               maxLines: 2,
                    //               overflow: TextOverflow.ellipsis),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            );
          },
        ),
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
