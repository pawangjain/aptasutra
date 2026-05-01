import 'package:aptasutra/app.dart';
import 'package:aptasutra/aptasutra.dart';
import 'package:aptasutra/main.dart';
import 'package:flutter/material.dart';

class StarButton extends StatefulWidget {
  final Aptasutra aptasutra;

  StarButton({required this.aptasutra});

  @override
  _StarButtonState createState() => _StarButtonState();
}

class _StarButtonState extends State<StarButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.aptasutra.isStarred ? Icons.star : Icons.star_border,
        color: widget.aptasutra.isStarred ? Colors.yellow : Colors.grey,
      ),
      onPressed: () => toggleStarredStatus(widget.aptasutra),
    );
  }

  toggleStarredStatus(Aptasutra q) {
    setState(() {
    q.isStarred = !q.isStarred;

    if (q.isStarred) {
      App.addToStarredList(q.n);
    } else {
      App.removeFromStarredList(q.n);
    }
    });
  }
}