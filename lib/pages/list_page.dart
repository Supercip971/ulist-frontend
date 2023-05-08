import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/register_page.dart';
import 'package:ulist/pocket_base.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:ulist/utils.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.id, required this.name});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String id;
  final String name;

  @override
  State<ListPage> createState() => _ListPage();
}

class _ListPage extends State<ListPage> {
  ShoppingList self = ShoppingList();
  List<ShoppingListEntry> entries = [];

  bool loaded = false;

  Future<bool> upload_change(int place) async {
    var pbc = getIt<PocketBaseController>();
    var entry = entries[place];

    ShoppingListEntryUpdate update = ShoppingListEntryUpdate();
    update.id = entries[place].uid;
    update.checked = entries[place].checked;

    update.name = entries[place].name;

    var result = await pbc.list_entry_update(self, update);
    return result;
  }

  Future<bool> load_data(bool hard) async {
    if (loaded && !hard) {
      return false;
    }
    var pbc = getIt<PocketBaseController>();
    var list = await pbc.get_list(widget.id);
    self = list;

    entries = await pbc.get_list_entries(list);

    loaded = true;

    return true;
  }

  Widget entry_widget(ShoppingListEntry entry, int place) {
    return Row(
      children: [
        Checkbox(
          value: entry.checked,
          onChanged: (value) {
            setState(() {
              entries[place].checked = value!;
              upload_change(place);
            });
          },
        ),
        Text(entry.name),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: FutureBuilder<bool>(
        future: load_data(false),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> widget_entries = [];
            for (var item in entries) {
              widget_entries.add(entry_widget(item, entries.indexOf(item)));
            }
            return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${self.name}"),
                  Column(
                    children: widget_entries,
                  )
                ]);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
