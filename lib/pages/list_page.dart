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

  TextEditingController addedName = TextEditingController();

  ShoppingListEntry current_being_edited = ShoppingListEntry();

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

  Widget add_entry_page(ShoppingListEntry entry) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add entry"),
      ),
      body: Column(
        children: [
          Text("Add entry"),
          TextField(
            controller: TextEditingController(text: entry.name),
            onChanged: (value) {
              entry.name = value;
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, entry);
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }

  Widget entry_widget(
      BuildContext context, ShoppingListEntry entry, int place) {
    TextStyle default_style = Theme.of(context).textTheme.bodyLarge!.copyWith(
          overflow: TextOverflow.ellipsis,
        );

    TextStyle checked_style = default_style.copyWith(
        decoration: TextDecoration.lineThrough, color: Colors.grey);
    return Row(
      mainAxisSize: MainAxisSize.max,
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
        Flexible(
          child: Container(
              child: Text(entry.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: ((entry.checked) ? checked_style : default_style))),
        )
      ],
    );
  }

  void openDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SizedBox(
          height: 400,
          child: Dialog(
              child: pad(Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                pad(
                  Text("Add entry",
                      style: Theme.of(context).textTheme.headlineLarge),
                )
              ]),
              pad(TextField(
                controller: TextEditingController(text: ""),
                onChanged: (value) {},
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Name",
                    icon: Icon(Icons.add)),
              )),
              pad(ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ))
            ],
          )))),
    );
  }

  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: Center(
            heightFactor: 1.0,
            child: Column(children: [
              Flexible(
                child: FutureBuilder<bool>(
                  future: load_data(true),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> widget_entries = [];
                      for (var item in entries) {
                        widget_entries.add(pad(entry_widget(
                            context, item, entries.indexOf(item))));
                      }

                      return Column(children: [
                        Expanded(
                            child: ListView(
                          children: widget_entries,
                        ))
                      ]);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              pad(Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Checkbox(
                    value: current_being_edited.checked,
                    onChanged: (value) {
                      setState(() {
                        current_being_edited.checked = value!;
                      });
                    },
                  ),
                  Flexible(
                    child: Container(
                      child: padx(TextField(
                        controller: addedName,
                        onChanged: (value) {},
                      )),
                    ),
                  ),
                  FloatingActionButton(
                      onPressed: () => {
                            setState(() {
                              ShoppingListEntryPush entry =
                                  ShoppingListEntryPush();

                              entry.checked = false;
                              entry.name = addedName.text;

                              pbc.list_entry_add(self, entry);
                            })
                          },
                      child: const Icon(Icons.add))
                ],
              ))
            ])));
  }
}
