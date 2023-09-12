// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:postinaja/nav_bar.dart';
import 'package:postinaja/post_card.dart';
import 'package:postinaja/post_create.dart';
import 'package:postinaja/profile.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required Text title});

  @override
  PostsState createState() => PostsState();
}

class PostsState extends State<Posts> {
  int _pageIndex = 0;
  List<dynamic>? _posts = [];

  final TextEditingController _authorFilter = TextEditingController();
  final TextEditingController _searchField = TextEditingController();
  String? _dateStartFilter;
  String? _dateEndFilter;

  Future<List<dynamic>> getData() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    //
    final response = await http.get(
        Uri(
            host: '192.168.160.28',
            scheme: 'http',
            port: 8000,
            path: '/api/posts',
            queryParameters: {
              'author': _authorFilter.text,
              'date_start': _dateStartFilter,
              'date_end': _dateEndFilter,
              'search': _searchField.text,
            }),
        headers: {'Authorization': 'Bearer $token'});
    debugPrint(response.body);

    if (response.statusCode == 500) {
      return [];
    }

    setState(() {
      _posts = jsonDecode(response.body);
    });

    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();
    getData();
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
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 20.0,
          ),
        ),
        appBarTheme:
            const AppBarTheme(backgroundColor: Color.fromRGBO(230, 138, 0, 1)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: [
            const Text('Post in Aja'),
            const Text('New Post'),
            const Text('Profile'),
          ][_pageIndex],
        ),
        bottomNavigationBar: NavBar(
          pageIndex: _pageIndex,
          setPageIndex: (index) {
            setState(() {
              _pageIndex = index;
            });
          },
        ),
        body: [
          RefreshIndicator(
            onRefresh: () async {
              var data = await getData();
              setState(() {
                _posts = [];
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                setState(() {
                  _posts = data;
                });
              });
            },
            child: LayoutBuilder(
              builder: (context, constrain) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constrain.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextFormField(
                            controller: _searchField,
                            onChanged: (value) async {
                              var data = await getData();
                              setState(() {
                                _posts = [];
                              });
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                setState(() {
                                  _posts = data;
                                });
                              });
                            },
                            decoration: InputDecoration(
                              constraints:
                                  BoxConstraints(maxWidth: constrain.maxWidth),
                              labelText: 'Search...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _searchField.text == ''
                                      ? Container()
                                      : IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _searchField.text = '';
                                            });
                                          },
                                          icon: const Icon(Icons.close),
                                        ),
                                  IconButton(
                                    alignment: Alignment.topRight,
                                    onPressed: () {
                                      showModalBottomSheet(
                                        enableDrag: false,
                                        context: context,
                                        showDragHandle: true,
                                        builder: (context) => Padding(
                                          padding: EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 8,
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Wrap(
                                                alignment: WrapAlignment.end,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _authorFilter.text = '';
                                                        _dateStartFilter = '';
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.delete),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _posts = [];
                                                      });
                                                      Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  100), () {
                                                        getData();
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    style: const ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStatePropertyAll(
                                                        Color(0xFFFF8C00),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Apply',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 255, 255, 255),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              TextFormField(
                                                autofocus: true,
                                                controller: _authorFilter,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Author',
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  var date =
                                                      await showDateRangePicker(
                                                    context: context,
                                                    initialDateRange:
                                                        DateTimeRange(
                                                            start:
                                                                DateTime.now(),
                                                            end:
                                                                DateTime.now()),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(3000),
                                                  );
                                                  if (date == null) return;
                                                  setState(() {
                                                    _dateStartFilter =
                                                        DateFormat('y-MM-dd')
                                                            .format(date.start);
                                                  });
                                                },
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color(0xFFFF8C00),
                                                  ),
                                                ),
                                                child: Text(
                                                  '''
                          Published Date: $_dateStartFilter - $_dateEndFilter''',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.filter_alt),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //     IconButton(
                        //       alignment: Alignment.topRight,
                        //       onPressed: () {
                        //         showModalBottomSheet(
                        //           enableDrag: false,
                        //           context: context,
                        //           showDragHandle: true,
                        //           builder: (context) => Padding(
                        //             padding: EdgeInsets.only(
                        //               left: 8,
                        //               right: 8,
                        //               top: 8,
                        //               bottom: MediaQuery.of(context)
                        //                   .viewInsets
                        //                   .bottom,
                        //             ),
                        //             child: Column(
                        //               mainAxisSize: MainAxisSize.min,
                        //               children: [
                        //                 Wrap(
                        //                   alignment: WrapAlignment.end,
                        //                   children: [
                        //                     IconButton(
                        //                       onPressed: () {
                        //                         setState(() {
                        //                           _authorFilter.text = '';
                        //                           _dateStartFilter = '';
                        //                         });
                        //                       },
                        //                       icon: const Icon(Icons.delete),
                        //                     ),
                        //                     TextButton(
                        //                       onPressed: () {
                        //                         setState(() {
                        //                           _posts = [];
                        //                         });
                        //                         Future.delayed(
                        //                             const Duration(
                        //                                 milliseconds: 100), () {
                        //                           getData();
                        //                         });
                        //                         Navigator.pop(context);
                        //                       },
                        //                       style: const ButtonStyle(
                        //                         backgroundColor:
                        //                             MaterialStatePropertyAll(
                        //                           Color(0xFFFF8C00),
                        //                         ),
                        //                       ),
                        //                       child: const Text(
                        //                         'Apply',
                        //                         style: TextStyle(
                        //                           color: Color.fromARGB(
                        //                               255, 255, 255, 255),
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //                 TextFormField(
                        //                   autofocus: true,
                        //                   controller: _authorFilter,
                        //                   decoration: const InputDecoration(
                        //                     labelText: 'Author',
                        //                   ),
                        //                 ),
                        //                 TextButton(
                        //                   onPressed: () async {
                        //                     var date =
                        //                         await showDateRangePicker(
                        //                       context: context,
                        //                       initialDateRange: DateTimeRange(
                        //                           start: DateTime.now(),
                        //                           end: DateTime.now()),
                        //                       firstDate: DateTime(2000),
                        //                       lastDate: DateTime(3000),
                        //                     );
                        //                     if (date == null) return;
                        //                     setState(() {
                        //                       _dateStartFilter =
                        //                           DateFormat('y-MM-dd')
                        //                               .format(date.start);
                        //                     });
                        //                   },
                        //                   style: const ButtonStyle(
                        //                     backgroundColor:
                        //                         MaterialStatePropertyAll(
                        //                       Color(0xFFFF8C00),
                        //                     ),
                        //                   ),
                        //                   child: Text(
                        //                     '''
                        // Published Date: $_dateStartFilter - $_dateEndFilter''',
                        //                     style: const TextStyle(
                        //                         color: Colors.white),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         );
                        //       },
                        //       icon: const Icon(Icons.filter_alt),
                        //     ),
                        for (var post in _posts!)
                          PostCard(
                            post: post,
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          PostCreate(onCreate: () async {
            var data = await getData();
            setState(() {
              _posts = [];
              _pageIndex = 0;
            });
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                _posts = data;
              });
            });
          }),
          const Profile()
        ][_pageIndex],
      ),
    );
  }
}
