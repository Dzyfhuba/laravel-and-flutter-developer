import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostShow extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostShow({Key? key, required this.post}) : super(key: key);

  @override
  PostShowState createState() => PostShowState();
}

class PostShowState extends State<PostShow> {
  Map<String, dynamic>? _post;
  String? _token;
  TextEditingController commentField = TextEditingController();
  final _commentForm = GlobalKey<FormState>();

  void getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    var response = await http.get(
      Uri(
        host: '192.168.131.28',
        scheme: 'http',
        port: 8000,
        path: '/api/posts/${widget.post["id"]}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('/api/posts/${_post?["id"]}');
    debugPrint(_token);
    setState(() {
      _post = jsonDecode(response.body);
      _token = token;
    });

    // setState(() {
    //   _post = ;
    // });
    // setState(() {
    // });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<bool> handleComment() async {
    if (!_commentForm.currentState!.validate()) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    var response = await http.post(
        Uri(
          host: '192.168.131.28',
          port: 8000,
          scheme: 'http',
          path: '/api/posts/${_post?["id"]}/comments',
        ),
        body: jsonEncode({'comment': commentField.text}),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json"
        });
    debugPrint('/api/posts/${_post?["id"]}/comments');
    debugPrint(response.body.toString());
    if (response.statusCode == 500) {
      return false;
    }
    if (response.statusCode == 201) {
      commentField.clear();
      getData();
      return true;
    }

    return false;
  }

  void handleThumb(String action) async {
    var response = await http.get(
        Uri(
          host: '192.168.131.28',
          scheme: 'http',
          port: 8000,
          path: '/api/posts/${_post?["id"]}/$action',
        ),
        headers: {'Authorization': 'Bearer $_token'});
    debugPrint(response.body);
    if (response.statusCode == 500) {
      return;
    }
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cardTheme: const CardTheme(
          shadowColor: Color(0xFFFF8C00),
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 20.0)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(230, 138, 0, 1),
        ),
        // iconButtonTheme: const IconButtonThemeData(
        //   style: ButtonStyle(
        //     iconColor: MaterialStatePropertyAll(
        //       Color(0xFFFF8C00),
        //     ),
        //   ),
        // ),
      ),
      home: Scaffold(
        appBar: AppBar(
            leading: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                // child: const Text('datasda',
                //     style: TextStyle(color: Color(0xFFFFFFFF))),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xffffffff),
                  size: 44,
                ))),
        // body: RefreshIndicator(
        //   onRefresh: () async {
        //     // var data = await getData();
        //     // setState(() {
        //     //   _posts = [];
        //     // });
        //     // Future.delayed(const Duration(milliseconds: 100), () {
        //     //   setState(() {
        //     //     _posts = data;
        //     //   });
        //     // });
        //   },
        //   child: LayoutBuilder(
        //     builder: (context, constrain) {
        //       return SingleChildScrollView(
        //         child: ConstrainedBox(
        //           constraints: BoxConstraints(minHeight: constrain.maxHeight),
        //           child: Column(
        //             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             crossAxisAlignment: CrossAxisAlignment.stretch,
        //             children: [for (int i = 0; i < 100; i++) const Text('asd')],
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
        body: RefreshIndicator(
          onRefresh: () async {
            getData();
          },
          child: LayoutBuilder(
            builder: (context, constrain) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constrain.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _post?['author'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('dd/MM/y').format(DateTime.parse(
                                      _post?['published_date'] ??
                                          DateTime.now().toString())),
                                  textScaleFactor: 0.6,
                                  style:
                                      const TextStyle(color: Color(0xFF8B8B8B)),
                                ),
                                Text(
                                  _post?['content'] ?? '',
                                  textScaleFactor: 0.8,
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(18),
                                              bottomLeft: Radius.circular(18),
                                            ),
                                            side: BorderSide(
                                              color: Colors.red,
                                              strokeAlign: 0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        handleThumb('like');
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.thumb_up_rounded,
                                            color: Color(0xFFFF8C00),
                                          ),
                                          Text(
                                            (_post?['likes'] ?? '').toString(),
                                            style: const TextStyle(
                                              color: Color(0xFFFF8C00),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        handleThumb('dislike');
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(18),
                                              bottomRight: Radius.circular(18),
                                            ),
                                            side: BorderSide(
                                              color: Colors.red,
                                              strokeAlign: 0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.thumb_down_rounded,
                                            color: Color(0xFFFF8C00),
                                          ),
                                          Text(
                                            (_post?['dislikes'] ?? '')
                                                .toString(),
                                            style: const TextStyle(
                                              color: Color(0xFFFF8C00),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Card(
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const ButtonBar(
                                  alignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'Comments',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Form(
                                  key: _commentForm,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        onEditingComplete: () {
                                          debugPrint('comment');
                                          handleComment();
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Comment Here',
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              debugPrint('comment');
                                              handleComment();
                                            },
                                            icon: const Icon(Icons.send,
                                                color: Color(0xFFFF8C00)),
                                          ),
                                        ),
                                        controller: commentField,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'This field is required';
                                          }

                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // for (int i = 0; i < 100; i++) const Text('asd')
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
