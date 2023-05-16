import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ulist/components/list_entry.dart';
import 'package:ulist/list.dart';
import 'package:ulist/listRequestCacher.dart';
import 'package:ulist/pages/dummy_list_page.dart';
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
  final OverlayEntry? overlay_entry = null;

  @override
  State<ListPage> createState() => _ListPage();
}

List<ShoppingListEntry> reorderShoppingListEntries(
    List<ShoppingListEntry> entries) {
  List<ShoppingListEntry> checked = [];
  List<ShoppingListEntry> unchecked = [];
  for (var item in entries) {
    if (item.checked) {
      checked.add(item);
    } else {
      unchecked.add(item);
    }
  }
  checked.sort((a, b) => a.name.compareTo(b.name));
  unchecked.sort((a, b) => a.name.compareTo(b.name));
  unchecked.addAll(checked);
  return unchecked;
}

class _ListPage extends State<ListPage> {
  ShoppingList self = ShoppingList();
  List<ShoppingListEntry> entries = [];
  

  TextEditingController addedName = TextEditingController();

  ShoppingListEntry current_being_edited = ShoppingListEntry();
  AnimatedListState animatedListState = AnimatedListState();
  bool dirty = true;
  bool loading = true;
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
    loading = true;

      
    if (!dirty && !hard) {
      
      if(loading){
        setState(() {
          loading = false;
        });
      }

      return false;
    }

    print("Reloading...");
    setState(() {
      loading = true;
    });
    var pbc = getIt<PocketBaseController>();

    self.uid = widget.id;
    self.name = widget.name;
    entries = await getIt<ListRequestCacher>()
        .get_list_entries_cached(self, refresh_cache: true);

    
    setState(() {
      loading = false;
      dirty = false;
    });
    return true;
  }

  Widget add_entry_page(ShoppingListEntry entry) {
    return Scaffold(
      appBar: AppBar(
          title: Hero(
              tag: 'title-hero-${widget.id}',
              child: Text(widget.name.toString(),
                  style: Theme.of(context).textTheme.bodyLarge))),
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

  final GlobalKey<AnimatedListState> _key = GlobalKey();

  Widget listEntries() {
    List<Widget> widget_entries = [];

    entries = reorderShoppingListEntries(entries);
    for (var item in entries) {
      int i = entries.indexOf(item);
      widget_entries.add(ListEntry(
          id: i,
          entry: entries[i],
          onChanged: (new_entry, id, slide) {
            var prev = entries[i];
            entries[i].checked = new_entry.checked;

            upload_change(i);

            if (slide) {
              _key.currentState!.removeItem(
                  id,
                  (context, animation) => SizeTransition(
                      sizeFactor: animation,
                      child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(10, 0),
                            end: const Offset(10, 0),
                          ).animate(animation),
                          child: ListEntry(
                            id: i,
                            entry: prev,
                            onChanged: (entry, id, swpi) {},
                          ))),
                  duration: const Duration(milliseconds: 300));
            } else {
              _key.currentState!.removeItem(
                  id,
                  (context, animation) => SizeTransition(
                      sizeFactor: animation,
                      child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset(0, 0),
                          ).animate(animation),
                          child: ListEntry(
                            id: i,
                            entry: prev,
                            onChanged: (entry, id, swpi) {},
                          ))),
                  duration: const Duration(milliseconds: 300));
            }

            _key.currentState!
                .insertItem(i, duration: const Duration(milliseconds: 0));

            // entries.removeAt(i);
            //  entries.add(new_entry);
            setState(() {});
          }));
    }

    return pad(Column(children: [
      Expanded(
          child: AnimatedList(
        key: _key,
        initialItemCount: widget_entries.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
              sizeFactor: animation, child: widget_entries[index]);
        },
      ))
    ]));
  }

  Widget entryLoader() {
    self.uid = widget.id;
    self.name = widget.name;

    return FutureBuilder<bool>(
      future: load_data(false),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return listEntries();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return dummy_list_entries(self);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();

    return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Text(widget.name.toString(),
                style: Theme.of(context).textTheme.headlineSmall),
            if (loading) padx(const CircularProgressIndicator(), factor: 3.0)
          ]),
        ),
        body: Center(
            heightFactor: 1.0,
            child: Column(children: [
              Flexible(
                child: entryLoader(),
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
                              dirty = true;
                            })
                          },
                      child: const Icon(Icons.add))
                ],
              ))
            ])));
  }
}
