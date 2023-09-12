// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:postinaja/comment_card.dart';
import 'package:postinaja/posts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostShow extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostShow({Key? key, required this.post}) : super(key: key);

  @override
  PostShowState createState() => PostShowState();
}

class PostShowState extends State<PostShow> {
  Map<String, dynamic>? _post;
  String? _token;
  TextEditingController commentField = TextEditingController();
  final _commentForm = GlobalKey<FormState>();
  List<dynamic> _comments = [];
  Map<String, dynamic>? _user;
  bool _isEditable = false;
  final _postForm = GlobalKey<FormState>();
  final TextEditingController _contentField = TextEditingController();
  final TextEditingController _titleField = TextEditingController();
  bool _statusField = true;
  String _publishedDateField = '';

  void getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    var response = await http.get(
      Uri(
        host: '192.168.160.28',
        scheme: 'http',
        port: 8000,
        path: '/api/posts/${widget.post["id"]}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    var responseComment = await http.get(
      Uri(
        host: '192.168.160.28',
        scheme: 'http',
        port: 8000,
        path: '/api/posts/${widget.post["id"]}/comments',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    String? user = prefs.getString('user');

    debugPrint(responseComment.body);
    setState(() {
      _post = jsonDecode(response.body);
      _token = token;
      _user = jsonDecode(user!);
      _comments = jsonDecode(responseComment.body);

      _contentField.text = jsonDecode(response.body)['content'];
      _titleField.text = jsonDecode(response.body)['title'];
      _publishedDateField = jsonDecode(response.body)['published_date']
          .toString()
          .substring(0, 10);
      _statusField = jsonDecode(response.body)['status'].toString() == '1';
    });
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<bool> handleComment() async {
    if (!_commentForm.currentState!.validate()) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    var response = await http.post(
        Uri(
          host: '192.168.160.28',
          port: 8000,
          scheme: 'http',
          path: '/api/posts/${_post?["id"]}/comments',
        ),
        body: jsonEncode({'comment': commentField.text}),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json",
        });
    debugPrint('/api/posts/${_post?["id"]}/comments');
    debugPrint(response.body.toString());
    if (response.statusCode == 500) {
      return false;
    }
    if (response.statusCode == 201) {
      commentField.clear();
      setState(() {
        _comments = [];
      });
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          getData();
        },
      );
      return true;
    }

    return false;
  }

  void handleThumb(String action) async {
    var response = await http.get(
        Uri(
          host: '192.168.160.28',
          scheme: 'http',
          port: 8000,
          path: '/api/posts/${_post?["id"]}/$action',
        ),
        headers: {'Authorization': 'Bearer $_token'});
    debugPrint(response.body);
    if (response.statusCode == 500) {
      return;
    }
    getData();
  }

  void submitPost() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    var body = {
      'title': _titleField.text,
      'content': _contentField.text,
      'status': _statusField,
      'published_date': _publishedDateField
    };

    debugPrint(jsonEncode(body));

    if (!_postForm.currentState!.validate()) {
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

    var response = await http.put(
      Uri(
        host: '192.168.160.28',
        port: 8000,
        scheme: 'http',
        path: '/api/posts/${_post?["id"]}',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    debugPrint(jsonEncode(body));
    debugPrint(response.body);

    if (response.statusCode == 201) {
      Future.sync(() => Navigator.pushReplacementNamed(context, '/'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cardTheme: const CardTheme(
          shadowColor: Color(0xFFFF8C00),
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 20.0)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(230, 138, 0, 1),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: _isEditable
              ? TextFormField(
                  controller: _titleField,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (value.length < 5) {
                      return 'This field must be more than 4 characters';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Type content here..',
                  ),
                )
              : Text(_post?['title'] ?? ''),
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xffffffff),
              size: 44,
            ),
          ),
        ),
        body: (_post == null && _user == null)
            ? const Center(child: Text('Loading...'))
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _comments = [];
                  });
                  Future.delayed(
                    const Duration(microseconds: 100),
                    () {
                      getData();
                    },
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constrain) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constrain.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              child: SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Wrap(
                                            children: [
                                              Text(
                                                _post?['author'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              (_post?['author'] ==
                                                      _user?['name'])
                                                  ? Icon(_post?['status'] == 1
                                                      ? Icons.visibility
                                                      : Icons.visibility_off)
                                                  : Container()
                                            ],
                                          ),
                                          _user?['name'] == _post?['author']
                                              ? PopupMenuButton(
                                                  onSelected: (value) async {
                                                    if (value == 'edit') {
                                                      setState(() {
                                                        _isEditable = true;
                                                      });
                                                    } else if (value ==
                                                        'delete') {
                                                      var response =
                                                          await http.delete(
                                                        Uri(
                                                          host:
                                                              '192.168.160.28',
                                                          port: 8000,
                                                          scheme: 'http',
                                                          path:
                                                              '/api/posts/${_post?["id"]}',
                                                        ),
                                                        headers: {
                                                          'Authorization':
                                                              'Bearer $_token'
                                                        },
                                                      );
                                                      debugPrint(response.body);
                                                      if (response.statusCode ==
                                                          200) {
                                                        Future.sync(
                                                          () => Navigator
                                                              .pushReplacement(
                                                            context,
                                                            PageTransition(
                                                              child:
                                                                  const Posts(
                                                                title: Text(
                                                                    'Posts'),
                                                              ),
                                                              type:
                                                                  PageTransitionType
                                                                      .fade,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else if (value ==
                                                        'closeEdit') {
                                                      setState(() {
                                                        _isEditable = false;
                                                      });
                                                    }
                                                  },
                                                  itemBuilder: (context) =>
                                                      _isEditable
                                                          ? <PopupMenuEntry>[
                                                              const PopupMenuItem(
                                                                value:
                                                                    'closeEdit',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .cancel,
                                                                        size:
                                                                            18),
                                                                    Text(
                                                                        'close')
                                                                  ],
                                                                ),
                                                              )
                                                            ]
                                                          : [
                                                              const PopupMenuItem(
                                                                value: 'edit',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .edit,
                                                                        size:
                                                                            18),
                                                                    Text('Edit')
                                                                  ],
                                                                ),
                                                              ),
                                                              const PopupMenuItem(
                                                                value: 'delete',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        size:
                                                                            18),
                                                                    Text(
                                                                        'Delete')
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                )
                                              : Container()
                                        ],
                                      ),
                                      _isEditable
                                          ? Form(
                                              key: _postForm,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text('Status: '),
                                                      Switch(
                                                        activeColor:
                                                            const Color(
                                                                0xFFE68A00),
                                                        value: _statusField,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _statusField =
                                                                value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: TextButton(
                                                      style: const ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                          Color.fromRGBO(230,
                                                              138, 0, 0.531),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        var date =
                                                            await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime(
                                                              DateTime.now()
                                                                  .year,
                                                              DateTime.now()
                                                                  .month,
                                                              DateTime.now()
                                                                  .day),
                                                          firstDate: DateTime
                                                              .parse(DateTime
                                                                      .now()
                                                                  .toString()
                                                                  .substring(
                                                                      0, 10)),
                                                          lastDate:
                                                              DateTime.parse(
                                                                  '2099-12-31'),
                                                        );
                                                        if (date == null) {
                                                          return;
                                                        }
                                                        setState(() {
                                                          _publishedDateField =
                                                              DateFormat(
                                                                      'y-MM-dd')
                                                                  .format(date);
                                                        });
                                                      },
                                                      child: Text(
                                                        'Published Date: $_publishedDateField',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    controller: _contentField,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'This field is required';
                                                      }
                                                      if (value.length < 5) {
                                                        return 'This field must be more than 4 characters';
                                                      }
                                                      return null;
                                                    },
                                                    minLines: 5,
                                                    maxLength: 1000,
                                                    maxLines: null,
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Type content here..',
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: TextButton(
                                                      style: const ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStatePropertyAll(
                                                        Color(0xFFE68A00),
                                                      )),
                                                      onPressed: () {
                                                        submitPost();
                                                      },
                                                      child: const Text('Save',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF000000),
                                                          )),
                                                    ),
                                                  )
                                                ],
                                              ))
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  DateFormat('dd/MM/y').format(
                                                    DateTime.parse(
                                                      _post?['published_date'] ??
                                                          DateTime.now()
                                                              .toString(),
                                                    ),
                                                  ),
                                                  textScaleFactor: 0.6,
                                                  style: const TextStyle(
                                                      color: Color(0xFF8B8B8B)),
                                                ),
                                                Text(
                                                  _post?['content'] ?? '',
                                                  textScaleFactor: 0.8,
                                                ),
                                              ],
                                            ),
                                      Row(
                                        children: [
                                          TextButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18),
                                                    bottomLeft:
                                                        Radius.circular(18),
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
                                                ),
                                                Text(
                                                  (_post?['likes'] ?? '')
                                                      .toString(),
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
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18),
                                                    bottomRight:
                                                        Radius.circular(18),
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
                                                ),
                                                Text(
                                                  (_post?['dislikes'] ?? '')
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Color(0xFFFF8C00),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              child: SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const ButtonBar(
                                        alignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                'Comments',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Form(
                                        key: _commentForm,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              onEditingComplete: () {
                                                debugPrint('comment');
                                                handleComment();
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Comment Here',
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    debugPrint('comment');
                                                    handleComment();
                                                  },
                                                  icon: const Icon(Icons.send,
                                                      color: Color(0xFFFF8C00)),
                                                ),
                                              ),
                                              controller: commentField,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'This field is required';
                                                }

                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          for (var comment in _comments)
                                            CommentCard(
                                              comment: comment,
                                              onRefresh: () {
                                                setState(() {
                                                  _comments = [];
                                                });
                                                Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100),
                                                  () {
                                                    getData();
                                                  },
                                                );
                                              },
                                            )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
