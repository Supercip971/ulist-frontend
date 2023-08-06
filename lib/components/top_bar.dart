import 'package:flutter/material.dart';

class UtopBar extends StatelessWidget {
  const UtopBar({Key? key, required this.title, required this.actions})
      : super(key: key);

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
    );
  }
}
