import 'package:flutter/material.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required Text title});

  @override
  State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // initialRoute: '/pages',
      home: Scaffold(
        body: Center(
          child: Text("data"),
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
