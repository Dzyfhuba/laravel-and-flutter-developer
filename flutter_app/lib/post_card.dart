import 'package:flutter/material.dart';
import 'package:flutter_app/post_show.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  Map<String, dynamic>? _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    setState(() {});
  }
  // PostCardState({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text('asd')
              Text(
                _post?['author'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post?['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _post?['content'],
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
