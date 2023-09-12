import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final _form = GlobalKey<FormState>();
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _nameField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();
  final TextEditingController _confirmationField = TextEditingController();

  Map<String, dynamic>? resposeErrorMessage = {};
  String? resposeSuccessMessage;

  bool _isValid = false;

  Future<bool> _saveForm() async {
    setState(() {
      _isValid = _form.currentState!.validate();
    });

    if (_form.currentState!.validate()) {
      return await formSubmit();
    }
    return _form.currentState!.validate();
  }

  Future<bool> formSubmit() async {
    if (_isValid) {
      var data = await http.post(
        Uri.http("192.168.160.28:8000", '/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            'email': _emailField.text,
            'name': _nameField.text,
            'password': _passwordField.text,
            'password_confirmation': _confirmationField.text,
          },
        ),
      );

      debugPrint(data.body);

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
        await prefs.setString('user', jsonEncode(body['user']));
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            // the Form here
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Register Page",
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                    keyboardType: TextInputType.name,
                    controller: _nameField,
                    validator: (value) {
                      // Check if this field is empty
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }

                      // using regular expression
                      if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                        return "Please enter a valid name";
                      }

                      // the email is valid
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailField,
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
                    controller: _passwordField,
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
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Password Confirmation'),
                    controller: _confirmationField,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/'),
                          child: const Text(
                            "Login if you already have an account.",
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              _saveForm().then(
                                (value) {
                                  if (value) {
                                    Navigator.of(context)
                                        .pushReplacementNamed("/posts");
                                  }
                                },
                              );
                            },
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(230, 138, 0, 1))),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            )),
                      ],
                    ),
                  ),
                  resposeErrorMessage!.containsKey("message")
                      ? Text(
                          resposeErrorMessage?['message'],
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
        ),
      ),
    );
  }
}
