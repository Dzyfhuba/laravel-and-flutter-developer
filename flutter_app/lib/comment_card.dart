import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:popover/popover.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  CommentCardState createState() => CommentCardState();
}

class CommentCardState extends State<CommentCard> {
  Map<String, dynamic>? _comment;
  bool _enableEdit = false;
  String _token = '';
  TextEditingController commentField = TextEditingController();
  final _commentForm = GlobalKey<FormState>();

  void getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    setState(() {
      _comment = widget.comment;
      _token = token!;
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
        host: '192.168.131.28',
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
                OpsiButton(
                  onEditPress: () {
                    setState(() {
                      _enableEdit = true;
                    });
                  },
                  onDeletePress: () {},
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
                                // debugPrint(commentField.text);
                                handleSave();
                              },
                            )),
                        // initialValue: _comment?['comment'] ?? '',
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
  const OpsiButton({
    super.key,
    required this.onEditPress,
    required this.onDeletePress,
  });

  // var _popoverKey

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => <PopupMenuEntry>[
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(Icons.edit, size: 18), Text('Edit')],
          ),
        )
      ],
    );
    // return
    //     // decoration: const BoxDecoration(
    //     //   color: Colors.white,
    //     //   borderRadius: BorderRadius.all(Radius.circular(5)),
    //     //   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
    //     // ),
    //     GestureDetector(
    //   child: const Center(child: Icon(Icons.more_vert)),
    //   onTap: () {
    //     showPopover(
    //       context: context,
    //       bodyBuilder: (context) => Column(
    //         children: [
    //           IconButton(
    //             icon: const Icon(Icons.edit, size: 18),
    //             onPressed: () {
    //               onEditPress();
    //             },
    //           ),
    //           IconButton(
    //             icon: const Icon(Icons.delete, size: 18),
    //             onPressed: () {},
    //           )
    //         ],
    //       ),
    //       onPop: () => debugPrint('Popover was popped!'),
    //       direction: PopoverDirection.top,
    //       width: 50,
    //       height: 100,
    //       arrowHeight: 15,
    //       arrowWidth: 30,
    //     );
    //   },
    // );
  }
}
