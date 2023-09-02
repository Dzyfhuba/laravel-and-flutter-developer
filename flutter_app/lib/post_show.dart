import 'package:flutter/material.dart';

class PostShow extends StatefulWidget {
  const PostShow({super.key, required Map<String, dynamic> post});

  @override
  PostShowState createState() => PostShowState();
}

class PostShowState extends State<PostShow> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          cardTheme:
              const CardTheme(shadowColor: Color.fromRGBO(230, 138, 0, 1)),
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 20.0)),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromRGBO(230, 138, 0, 1))),
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
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: SizedBox(
                          child: Column(
                            children: [Text('data')],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
