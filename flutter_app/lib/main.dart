import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/posts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // runApp(const MyApp());
  runApp(MaterialApp(
    // home: const LoginPage(title: Text('posts')),
    initialRoute: '/',
    routes: <String, WidgetBuilder>{
      '/': (context) => const LoginPage(title: Text('posts')),
      '/posts': (context) => const Posts(title: Text('posts')),
      // '/posts/show': (context) => const PostShow(),
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Posts LAh',
      home: LoginPage(title: Text('posts')),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final Text title;

  @override
  State<StatefulWidget> createState() => LoginForm();
}

class LoginForm extends State<LoginPage> {
  TextEditingController emailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isValid = false;
  Map<String, dynamic> resposeErrorMessage = {
    // "email": [],
    // "password": [],
  };
  String? resposeSuccessMessage;
  bool _isNetworkError = false;

  Future<bool> _saveForm() async {
    setState(() {
      _isValid = _form.currentState!.validate();
    });
    if (_form.currentState!.validate()) {
      await formSubmit();
      // debugPrint(emailField.text);
      // debugPrint(passwordField.text);
    }
    return _form.currentState!.validate();
  }

  bool _isLoading = true;

  Future<void> authCheck() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    debugPrint("token: $token");

    final response = await http.get(
      Uri(
        host: '192.168.131.28',
        port: 8000,
        scheme: 'http',
        path: 'api/auth/check',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        "Content-Type": "application/json"
      },
    ).catchError((err) async {
      setState(() {
        _isLoading = false;
        _isNetworkError = true;
      });
      return err;
    });

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 500) {
      return;
    }

    Map<String, dynamic> body = jsonDecode(response.body);

    if (body['isLoggedIn']) {
      Future(() {
        Navigator.pushReplacementNamed(context, '/posts');
        debugPrint(response.body);
      });
    }

    // return body['isLoggedIn'];
  }

  @override
  void initState() {
    super.initState();
    authCheck();
  }

  Future<void> formSubmit() async {
    if (_isValid) {
      var data = await http.post(
        Uri.http("192.168.131.28:8000", '/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            'email': emailField.text,
            'password': passwordField.text,
          },
        ),
      );

      final Map<String, dynamic> body = jsonDecode(data.body);

      if (data.statusCode == 400) {
        setState(() {
          resposeErrorMessage = body;
        });
      }
      debugPrint(data.body);
      if (data.statusCode == 201) {
        setState(() {
          resposeSuccessMessage = body['message'];
          resposeErrorMessage = {};
        });
        // obtain shared preferences
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', body['token']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Post Saja Lah", textScaleFactor: 2),
                SpinKitRing(
                  color: Colors.black,
                )
              ],
            )
          : _isNetworkError
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Network Error',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textScaleFactor: 2),
                      Text('Check Your Connection'),
                      Text('If not that, let us know'),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(25),
                  // the Form here
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Login Page",
                            textScaleFactor: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            // errorText: resposeMessage.containsKey("email") && resposeMessage['email'] != []
                            //     ? resposeMessage['email'].toString()
                            //     : null
                          ),
                          keyboardType: TextInputType.emailAddress,
                          controller: emailField,
                          validator: (value) {
                            // Check if this field is empty
                            if (value == null || value.isEmpty) {
                              return 'This field is required';
                            }

                            // using regular expression
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return "Please enter a valid email address";
                            }

                            // the email is valid
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          controller: passwordField,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          validator: (value) {
                            // Check if this field is empty
                            if (value == null || value.isEmpty) {
                              return 'This field is required';
                            }

                            // the email is valid
                            return null;
                          },
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: TextButton(
                              onPressed: () {
                                _saveForm().then(
                                  (value) {
                                    if (value) {
                                      Navigator.of(context)
                                          .pushReplacementNamed("/posts");
                                    } else {}
                                  },
                                );
                                // Navigator.of(context).pushNamed("/posts");
                              },
                              style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Color.fromRGBO(230, 138, 0, 1))),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.black),
                              )),
                        ),
                        resposeErrorMessage.containsKey("message")
                            ? Text(
                                resposeErrorMessage['message'],
                                style: const TextStyle(color: Colors.red),
                              )
                            : Container(),
                        resposeSuccessMessage != null
                            ? Text(resposeSuccessMessage!)
                            : Container()
                      ],
                    ),
                  ),
                ),
    );
  }
}
