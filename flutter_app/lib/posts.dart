import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required Text title});

  @override
  State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<Posts> {
  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    debugPrint(token);
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
                },
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Color.fromRGBO(230, 138, 0, 1))),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.black),
                )),
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
