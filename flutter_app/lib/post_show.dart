import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostShow extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostShow({Key? key, required this.post}) : super(key: key);

  @override
  PostShowState createState() => PostShowState();
}

class PostShowState extends State<PostShow> {
  Map<String, dynamic>? _post;

  @override
  void initState() {
    super.initState();

    setState(() {
      _post = widget.post;
    });
  }

  void handleLike() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cardTheme: const CardTheme(
          shadowColor: Color.fromARGB(255, 255, 140, 0),
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 20.0)),
        appBarTheme:
            const AppBarTheme(backgroundColor: Color.fromRGBO(230, 138, 0, 1)),
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
        body: LayoutBuilder(
          builder: (context, constrain) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constrain.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                _post?['author'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('dd/MM/y').format(
                                    DateTime.parse(_post?['published_date'])),
                                textScaleFactor: 0.6,
                                style:
                                    const TextStyle(color: Color(0xFF8B8B8B)),
                              ),
                              Text(
                                _post?['content'],
                                textScaleFactor: 0.8,
                              ),
                              Row(
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        debugPrint("like");
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.thumb_up_rounded),
                                          Text(_post!['likes'].toString())
                                        ],
                                      ))
                                ],
                              )
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
    );
  }
}
