import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'State Example',
      home: LoginPage(title: 'State Example'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

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

  Future<void> _saveForm() async {
    setState(() {
      _isValid = _form.currentState!.validate();
    });
    if (_form.currentState!.validate()) {
      formSubmit();
      debugPrint(emailField.text);
      debugPrint(passwordField.text);
    }
  }

  Future<void> formSubmit() async {
    if (_isValid) {
      var data = await http.post(Uri.http("192.168.131.28:8000", '/api/login'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'email': emailField.text,
            'password': passwordField.text,
          }));

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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        // the Form here
        child: Form(
          key: _form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text("Login Page",
                    textScaleFactor: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
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
                decoration: const InputDecoration(labelText: 'Password'),
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
                    onPressed: _saveForm,
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
