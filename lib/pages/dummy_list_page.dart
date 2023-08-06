import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cutelist/components/list_entry.dart';
import 'package:cutelist/components/list_entry_dummy.dart';
import 'package:cutelist/components/list_properties.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/listRequestCacher.dart';
import 'package:cutelist/pages/list_page.dart';
import 'package:cutelist/pages/register_page.dart';
import 'package:cutelist/pocket_base.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:cutelist/utils.dart';

class DummyListPage extends StatefulWidget {
  const DummyListPage({super.key, this.list});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final ShoppingList? list;

  @override
  State<DummyListPage> createState() => _DummyListPage();
}

Widget dummy_list_entries(ShoppingList? l) {
  List<Widget> widget_entries = [];
  List<ShoppingListEntry> entries = [];

  bool used_cache = false;
  // generating dummy entries

  if (l != null) {
    final cache_controller =
        getIt<ListRequestCacher>().get_list_entries_only_cached(l);

    if (cache_controller != null) {
      used_cache = true;
      entries = reorderShoppingListEntries(cache_controller, "");
    }
  }

  if (!used_cache) {
    for (var i = 0; i < 64; i++) {
      ShoppingListEntry entry = ShoppingListEntry();
      entry.name = "...";
      entry.checked = false;
      entry.addedBy = "user";
      entries.add(entry);
    }
  }

  for (var item in entries) {
    int i = entries.indexOf(item);
    widget_entries.add(DummyListEntry(
        id: i, entry: entries[i], onChanged: (new_entry, id, slide) {}));
  }

  return pad(Column(children: [
    Expanded(
        child: ListView.builder(
      itemCount: widget_entries.length,
      itemBuilder: (context, index) {
        return widget_entries[index];
      },
    ))
  ]));
}

class _DummyListPage extends State<DummyListPage> {
  List<ShoppingListEntry> entries = [];

  TextEditingController addedName = TextEditingController();

  ShoppingListEntry current_being_edited = ShoppingListEntry();
  AnimatedListState animatedListState = AnimatedListState();
  bool loaded = false;

  final GlobalKey<AnimatedListState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: (Text(
              widget.list == null ? ("List") : widget.list!.name.toString(),
              style: Theme.of(context).textTheme.headlineSmall)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => {},
          ),
          actions: [(ListPropertiesBar(entry: widget.list!))],
        ),
        body: Center(
            heightFactor: 1.0,
            child: Column(children: [
              Flexible(child: dummy_list_entries(widget.list)),
              pad(Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Checkbox(
                    value: current_being_edited.checked,
                    onChanged: (value) {},
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
                      onPressed: () => {},
                      child: const CircularProgressIndicator())
                ],
              ))
            ])));
  }
}
