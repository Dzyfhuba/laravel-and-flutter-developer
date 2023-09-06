import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:postinaja/post_show.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  Map<String, dynamic>? _post;
  Map<String, dynamic>? _user;

  void getData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _user = jsonDecode(prefs.getString('user')!);
    });
  }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  Text(
                    _post?['author'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  (_post?['author'] == _user?['name'])
                      ? Icon(_post?['status'] == 1
                          ? Icons.visibility
                          : Icons.visibility_off)
                      : Container()
                ],
              ),
              Text(
                DateFormat('dd/MM/y')
                    .format(DateTime.parse(_post?['published_date'])),
                textScaleFactor: 0.6,
                style: const TextStyle(color: Color(0xFF8B8B8B)),
              ),
              GestureDetector(
                onTap: () {
                  if (_post != null) {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: PostShow(post: _post!),
                            type: PageTransitionType.rightToLeft));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _post?['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _post!['content'].toString().replaceAll(
                            RegExp(r"<[^>]*>",
                                multiLine: true, caseSensitive: true),
                            ' ',
                          ),
                      textScaleFactor: 0.6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
