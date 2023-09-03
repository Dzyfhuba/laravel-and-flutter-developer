import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  CommentCardState createState() => CommentCardState();
}

class CommentCardState extends State<CommentCard> {
  Map<String, dynamic>? _comment;

  @override
  void initState() {
    super.initState();

    setState(() {
      _comment = widget.comment;
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
            Text(
              _comment?['name'] ?? '',
              textScaleFactor: 0.8,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _comment?['comment'] ?? '',
              textScaleFactor: 0.8,
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
