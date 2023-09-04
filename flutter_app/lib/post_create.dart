import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:intl/intl.dart';
// import 'package:flutter_quill/flutter_quill.dart';

class PostCreate extends StatefulWidget {
  const PostCreate({super.key});

  @override
  PostCreateState createState() => PostCreateState();
}

class PostCreateState extends State<PostCreate> {
  TextEditingController titleField = TextEditingController();
  QuillController contentField = QuillController.basic();
  bool statusField = false;
  String _publishedDateField = '';
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE68A00),
        onPressed: () {},
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
                ),
                Row(
                  children: [
                    const Text('Status: '),
                    Switch(
                      activeColor: Color(0xFFE68A00),
                      value: statusField,
                      onChanged: (value) {
                        setState(() {
                          statusField = value;
                        });
                      },
                    ),
                  ],
                ),
                // CalendarDatePicker(
                //   initialDate: DateTime.now(),
                //   firstDate: DateTime.now(),
                //   lastDate: DateTime.now(),
                //   onDateChanged: (value) {},
                // ),
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
                            DateFormat('y-MM-dd').format(date!);
                      });
                    },
                    child: Text('Published Date: $_publishedDateField',
                        style: const TextStyle(color: Colors.black)),
                  ),
                ),

                QuillToolbar.basic(
                  controller: contentField,
                ),
                Expanded(
                  child: QuillEditor.basic(
                    controller: contentField,
                    readOnly: false,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
