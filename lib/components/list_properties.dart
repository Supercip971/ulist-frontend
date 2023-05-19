import 'package:flutter/material.dart';
import 'package:ulist/list.dart';
import 'package:ulist/utils.dart';

class ListPropertiesBar extends StatefulWidget {
  const ListPropertiesBar({Key? key, required this.entry}) : super(key: key);

  final ShoppingList entry;
  @override
  State<ListPropertiesBar> createState() => _ListPropertiesBar();
}

class _ListPropertiesBar extends State<ListPropertiesBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return padx(Row(children: [
      IconButton(onPressed: () => {}, icon: Icon(Icons.person_add)),
      IconButton(onPressed: () => {}, icon: Icon(Icons.star)),
      IconButton(onPressed: () => {}, icon: Icon(Icons.more_vert))
    ]));
  }
}