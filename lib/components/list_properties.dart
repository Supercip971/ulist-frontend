import 'package:flutter/material.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/pages/list_properties.dart';
import 'package:cutelist/pages/popups/invite-after.dart';
import 'package:cutelist/pages/popups/invite.dart';
import 'package:cutelist/utils.dart';

class ListPropertiesBar extends StatefulWidget {
  const ListPropertiesBar(
      {Key? key, required this.entry, this.startFilter = null})
      : super(key: key);

  final Function(BuildContext)? startFilter;

  final ShoppingList entry;
  @override
  State<ListPropertiesBar> createState() => _ListPropertiesBar();
}

class _ListPropertiesBar extends State<ListPropertiesBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return padx(Row(children: [
      IconButton(
          onPressed: () => {
                if (widget.startFilter != null) {widget.startFilter!(context)}
              },
          icon: Icon(Icons.filter_list)),
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
      IconButton(
          onPressed: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ListPropertiesPage(id: widget.entry.uid)))
              },
          icon: Icon(Icons.more_vert)),
    ]));
  }
}
