import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required Text title});

  @override
  State<StatefulWidget> createState() => PostsState();
}

class PostsState extends State<Posts> {
  String? _token;
  int _counter = 0;

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    setState(() {
      _token = token;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    // SharedPreferences.getInstance()
    //     .then((value) => _token = value.getString('token'));
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
