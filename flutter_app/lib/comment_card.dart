import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> comment;
  final void Function() onRefresh;

  const CommentCard({Key? key, required this.comment, required this.onRefresh})
      : super(key: key);

  @override
  CommentCardState createState() => CommentCardState();
}

class CommentCardState extends State<CommentCard> {
  Map<String, dynamic>? _comment;
  bool _enableEdit = false;
  String _token = '';
  Map<String, dynamic>? _user;
  TextEditingController commentField = TextEditingController();
  final _commentForm = GlobalKey<FormState>();

  void getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    String? user = prefs.getString('user');

    setState(() {
      _comment = widget.comment;
      _token = token!;
      _user = jsonDecode(user!);
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<bool> handleSave() async {
    if (!_commentForm.currentState!.validate()) {
      return false;
    }
    var response = await http.put(
      Uri(
        host: '192.168.160.28',
        port: 8000,
        scheme: 'http',
        path: '/api/posts/comments/${_comment?["id"]}',
      ),
      headers: {
        'Authorization': 'Bearer $_token',
        "Content-Type": "application/json",
      },
      body: jsonEncode({'comment': commentField.text}),
    );

    debugPrint(response.body);

    if (response.statusCode == 201) {
      setState(() {
        _comment?['comment'] = jsonDecode(response.body)['comment']['comment'];
        _enableEdit = false;
      });
    }

    return response.statusCode == 201;
  }

  void handleThumb(String action) async {
    var response = await http.get(
        Uri(
          host: '192.168.160.28',
          scheme: 'http',
          port: 8000,
          path: '/api/posts/comments/${_comment?["id"]}/$action',
        ),
        headers: {'Authorization': 'Bearer $_token'});
    debugPrint(response.body);
    if (response.statusCode == 500) {
      return;
    }

    var data = jsonDecode(response.body);

    setState(() {
      _comment?['likes'] = data['likes'];
      _comment?['dislikes'] = data['dislikes'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF8C00)),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _comment?['name'] ?? '',
                  textScaleFactor: 0.8,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                (_user?['name'] != _comment?['name'])
                    ? Container()
                    : OpsiButton(
                        isEditable: _enableEdit,
                        onEditPress: () {
                          setState(() {
                            _enableEdit = !_enableEdit;
                          });
                        },
                        onDeletePress: () async {
                          var response = await http.delete(
                            Uri(
                              host: '192.168.160.28',
                              port: 8000,
                              scheme: 'http',
                              path: '/api/posts/comments/${_comment?["id"]}',
                            ),
                            headers: {'Authorization': 'Bearer $_token'},
                          );

                          if (response.statusCode != 200) {
                            return;
                          }

                          widget.onRefresh();
                        },
                      )
              ],
            ),
            Container(
              child: _enableEdit
                  ? Form(
                      key: _commentForm,
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: _comment?['comment'] ?? '',
                            hintStyle:
                                const TextStyle(color: Color(0xFF8B8B8B)),
                            hintMaxLines: 1,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () {
                                handleSave();
                              },
                            )),
                        controller: commentField,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }

                          return null;
                        },
                      ),
                    )
                  : Text(
                      _comment?['comment'] ?? '',
                      textScaleFactor: 0.8,
                    ),
            ),
            Row(
              children: [
                TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                        side: BorderSide(
                          color: Colors.red,
                          strokeAlign: 0,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    handleThumb('like');
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thumb_up_rounded,
                        color: Color(0xFFFF8C00),
                        size: 16,
                      ),
                      Text(
                        (_comment?['likes'] ?? '').toString(),
                        style: const TextStyle(
                          color: Color(0xFFFF8C00),
                        ),
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    handleThumb('dislike');
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        side: BorderSide(
                          color: Colors.red,
                          strokeAlign: 0,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thumb_down_rounded,
                        color: Color(0xFFFF8C00),
                        size: 16,
                      ),
                      Text(
                        (_comment?['dislikes'] ?? '').toString(),
                        style: const TextStyle(
                          color: Color(0xFFFF8C00),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Container(
              alignment: Alignment.topRight,
              child: Text(
                DateFormat('dd/MM/y').format(
                  DateTime.parse(
                    _comment?['published_date'] ?? DateTime.now().toString(),
                  ),
                ),
                textScaleFactor: 0.5,
                style: const TextStyle(
                  color: Color(0xFF8B8B8B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OpsiButton extends StatelessWidget {
  final void Function() onEditPress;
  final void Function() onDeletePress;
  final bool isEditable;

  const OpsiButton({
    super.key,
    required this.onEditPress,
    required this.onDeletePress,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == 'edit' || value == 'closeEdit') {
          onEditPress();
        } else if (value == 'delete') {
          onDeletePress();
        }
      },
      itemBuilder: (context) => isEditable
          ? <PopupMenuEntry>[
              const PopupMenuItem(
                value: 'closeEdit',
                child: Row(
                  children: [Icon(Icons.cancel, size: 18), Text('close')],
                ),
              )
            ]
          : <PopupMenuEntry>[
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [Icon(Icons.edit, size: 18), Text('Edit')],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [Icon(Icons.delete, size: 18), Text('Delete')],
                ),
              ),
            ],
    );
  }
}
