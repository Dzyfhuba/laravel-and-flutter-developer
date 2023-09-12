import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCreate extends StatefulWidget {
  final void Function() onCreate;
  const PostCreate({super.key, required this.onCreate});

  @override
  PostCreateState createState() => PostCreateState();
}

class PostCreateState extends State<PostCreate> {
  TextEditingController titleField = TextEditingController();
  TextEditingController contentField = TextEditingController();
  bool statusField = true;
  String _publishedDateField = '';
  final _form = GlobalKey<FormState>();

  void submitPost() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    var body = {
      'title': titleField.text,
      'content': contentField.text,
      'status': statusField,
      'published_date': _publishedDateField
    };

    debugPrint(jsonEncode(body));

    if (!_form.currentState!.validate()) {
      return;
    }

    var isValidated = await Future.sync(() {
      if (body['title'] == null || body['title'] == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title is required')),
        );
        return false;
      } else if (body['content'] == null || body['content'] == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content is required')),
        );
        return false;
      } else if (body['published_date'] == null ||
          body['published_date'] == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Published Date is required')),
        );
        return false;
      } else if (body['status'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status is required')),
        );
        return false;
      }
      return true;
    });

    if (!isValidated) return;
    var response = await http.post(
      Uri(
        host: '192.168.160.28',
        port: 8000,
        scheme: 'http',
        path: '/api/posts',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    debugPrint(response.body);
    debugPrint(jsonEncode(body));
    if (response.statusCode == 201) {
      widget.onCreate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE68A00),
        onPressed: () {
          submitPost();
        },
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _form,
          child: Container(
            decoration: BoxDecoration(border: Border.all()),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: titleField,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (value.length < 5) {
                      return 'This field must be more than 4 characters';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    const Text('Status: '),
                    Switch(
                      activeColor: const Color(0xFFE68A00),
                      value: statusField,
                      onChanged: (value) {
                        setState(() {
                          statusField = value;
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(230, 138, 0, 0.531)),
                    ),
                    onPressed: () async {
                      var date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.parse('2099-12-31'),
                      );
                      if (date == null) return;
                      setState(() {
                        _publishedDateField =
                            DateFormat('y-MM-dd').format(date);
                      });
                    },
                    child: Text('Published Date: $_publishedDateField',
                        style: const TextStyle(color: Colors.black)),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: contentField,
                    decoration: const InputDecoration(
                      hintText: 'Type your content here...',
                    ),
                    minLines: 5,
                    maxLength: 1000,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      if (value.length < 5) {
                        return 'This field must be more than 4 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
