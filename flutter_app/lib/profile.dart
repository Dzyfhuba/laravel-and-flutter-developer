import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  TextEditingController usernameField = TextEditingController();

  void getData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      usernameField.text = jsonDecode(prefs.getString('user')!)['name'];
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    labelText: 'Name',
                  ),
                  controller: usernameField,
                ),
              ],
            ),
          ),
          Card(
            color: Colors.red[100],
            child: TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Sure to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        String token = prefs.getString("token")!;
                        http.get(
                          Uri(
                              host: '192.168.160.28',
                              port: 8000,
                              scheme: 'http',
                              path: '/api/logout'),
                          headers: {'Authorization': 'Bearer $token'},
                        ).then((value) {
                          prefs.clear();
                          Navigator.pop(context, 'OK');
                          Navigator.pushReplacementNamed(context, '/');
                        });
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
