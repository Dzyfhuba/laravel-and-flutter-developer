import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class Quill extends StatefulWidget {
  final String? value;
  final void Function(String value) setValue;

  const Quill({super.key, this.value, required this.setValue});

  @override
  QuillState createState() => QuillState();
}

class QuillState extends State<Quill> {
  QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillToolbar.basic(controller: _controller),
        QuillEditor.basic(controller: _controller, readOnly: false),
      ],
    );
  }
}
