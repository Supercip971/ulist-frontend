import 'package:flutter/material.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/popups/invite-after.dart';
import 'package:ulist/pages/popups/invite.dart';
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
      IconButton(onPressed: () => {}, icon: Icon(Icons.filter_list)),
      IconButton(
          onPressed: () => {
                showListInvite(context, widget.entry).then(
                  (value) {
                    print(value?.code);
                    if (value?.code == null) return;

                    showListInvitationCode(context, value!.code, widget.entry);
                  },
                )
              },
          icon: Icon(Icons.person_add)),
      IconButton(onPressed: () => {}, icon: Icon(Icons.star)),
      IconButton(onPressed: () => {}, icon: Icon(Icons.more_vert)),
    ]));
  }
}
