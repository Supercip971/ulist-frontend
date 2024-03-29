import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cutelist/components/list_entry.dart';
import 'package:cutelist/components/list_properties.dart';
import 'package:cutelist/components/list_tag.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/listRequestCacher.dart';
import 'package:cutelist/pages/dummy_list_page.dart';
import 'package:cutelist/pages/popups/filter_popup.dart';
import 'package:cutelist/pages/register_page.dart';
import 'package:cutelist/pocket_base.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:cutelist/utils.dart';

class ListPage extends StatefulWidget {
  ListPage(
      {super.key, required this.id, required this.name, required this.tags});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String id;
  final String name;
  final List<String> tags;
  final OverlayEntry? overlay_entry = null;

  @override
  State<ListPage> createState() => _ListPage();
}

List<ShoppingListEntry> reorderShoppingListEntries(
    List<ShoppingListEntry> entries, String filter) {
  List<ShoppingListEntry> checked = [];
  List<ShoppingListEntry> unchecked = [];
  for (var item in entries) {
    if (filter != "" && !item.tags.contains(filter)) {
      continue;
    }
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

// returns the expected index if we were to insert the entry into the list
int shoppingListInsertedIndex(
    ShoppingListEntry entry, List<ShoppingListEntry> entries) {
  int index = 0;
  for (var item in entries) {
    if (item.checked == entry.checked) {
      if (item.name.compareTo(entry.name) > 0) {
        return index;
      }
    }
    index++;
  }
  return index;
}

class _ListPage extends State<ListPage> {
  ShoppingList self = ShoppingList();
  String filter = "";
  List<ShoppingListEntry> entries = [];

  TextEditingController addedName = TextEditingController();

  ShoppingListEntry current_being_edited = ShoppingListEntry();
  AnimatedListState animatedListState = AnimatedListState();
  bool dirty = true;
  bool loading = true;
  Future<bool> upload_change(int place, bool delete_entry) async {
    var pbc = getIt<PocketBaseController>();
    var entry = entries[place];

    ShoppingListEntryUpdate update = ShoppingListEntryUpdate();
    update.id = entries[place].uid;
    update.checked = entries[place].checked;

    update.delete = delete_entry;

    update.name = entries[place].name;

    var result = await pbc.list_entry_update(self, update);
    return result;
  }

  final GlobalKey<AnimatedListState> _key = GlobalKey();
  Future<bool> load_data(bool hard) async {
    loading = true;

    if (!dirty && !hard) {
      if (loading) {
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

  void applyFilter(String filter) {
    setState(() {
      this.filter = filter;
    });
  }

  Widget listEntries() {
    List<Widget> widget_entries = [];

    if (entries.length == 0) {
      return Center(
          child:
              Text("No entries, please create a new one using the + button"));
    }

    /*
	if(_key.currentState != null){
			_key.currentState!.removeAllItems((context, animation) => Container(), duration: Duration(milliseconds: 0));
	   setState(() {
	   	     
	   	   });
	}*/

    print("filter: '" + filter + "'");
    entries = reorderShoppingListEntries(entries, "");

    for (var item in entries) {
      int i = entries.indexOf(item);

      if (item.tags.contains(filter) || filter == "") {
        widget_entries.add(ListEntry(
            id: i,
            entry: entries[i],
            onChanged: (new_entry, id, slide, remove) {
              var prev = entries[i];

              upload_change(i, remove);

              if (remove) {
                _key.currentState!.removeItem(
                    id,
                    (context, animation) => SizeTransition(
                        sizeFactor: animation,
                        child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: const Offset(0, 0),
                            ).animate(animation),
                            child: ListEntry(
                              id: i,
                              entry: prev,
                              onChanged: (entry, id, swipe, removed) {},
                            ))),
                    duration: const Duration(milliseconds: 300));
              } else {
                entries[i].checked = new_entry.checked;

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
                                onChanged: (entry, id, swipe, removed) {},
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
                                onChanged: (entry, id, swipe, removed) {},
                              ))),
                      duration: const Duration(milliseconds: 300));
                }

                _key.currentState!
                    .insertItem(i, duration: const Duration(milliseconds: 0));

                // entries.removeAt(i);
                //  entries.add(new_entry);
              }
              setState(() {});
            }));
      } else {
        widget_entries.add(Container());
      }
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

  String old_filter = "";
  Widget entryLoader() {
    return FutureBuilder<bool>(
      future: load_data(old_filter != filter),
      builder: (context, snapshot) {
        old_filter = filter;
        if (snapshot.hasData) {
          return listEntries();
        } else if (snapshot.hasError) {
          print(snapshot.stackTrace);
          return Text("${snapshot.error}");
        }

        return dummy_list_entries(self);
      },
    );
  }

  List<String> selected_tag = [];

  bool showTags = false;

  @override
  Widget build(BuildContext context) {
    self.uid = widget.id;
    self.name = widget.name;
    self.tags = widget.tags;

    List<Widget> editing_tags_widget = [];

    for (var tag in self.tags) {
      editing_tags_widget.add(padx(
          ListTagButton(
              name: tag,
              highlighted: selected_tag.contains(tag),
              callback: () => {
                    setState(() {
                      if (selected_tag.contains(tag)) {
                        selected_tag.remove(tag);
                      } else {
                        selected_tag.add(tag);
                      }
                    })
                  }),
          factor: 0.5));
    }

    editing_tags_widget
        .add(IconButton.outlined(onPressed: () {}, icon: Icon(Icons.add)));

    var pbc = getIt<PocketBaseController>();

    Widget filterBar = Container();
    if (filter != "") {
      filterBar = Row(children: [
        Text("Filtering by: "),
        ListTagButton(name: filter, callback: () => {}),
        Spacer(),
        TextButton.icon(
            icon: Icon(Icons.clear),
            onPressed: () => {applyFilter("")},
            label: Text("Clear"))
      ]);
    }
    return Scaffold(
        appBar: AppBar(
            title: Row(children: [
              Text(widget.name.toString(),
                  style: Theme.of(context).textTheme.headlineSmall),
              if (loading) padx(const CircularProgressIndicator(), factor: 3.0)
            ]),
            actions: [
              ListPropertiesBar(
                entry: self,
                startFilter: (ctx) => {
                  showFilterSelection(context, self).then((result) => {
                        if (result != null && result.result != null)
                          {applyFilter(result.result!)}
                      })
                },
              )
            ]),
        body: Center(
            heightFactor: 1.0,
            child: Column(children: [
              padx(filterBar, factor: 3),
              Flexible(
                child: entryLoader(),
              ),
              pad(Column(children: [
                /* tag row */

                showTags ? Row(children: editing_tags_widget) : Container(),

                /* editing row */
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    showTags
                        ? IconButton.filled(
                            onPressed: () => {
                                  setState(() => {showTags = !showTags})
                                },
                            icon: Icon(Icons.local_offer))
                        : IconButton.outlined(
                            onPressed: () => {
                                  setState(() => {showTags = !showTags})
                                },
                            icon: Icon(Icons.local_offer)),
                    Flexible(
                      child: Container(
                        child: padx(TextField(
                          controller: addedName,
                          onChanged: (value) {},
                        )),
                      ),
                    ),
                    FloatingActionButton(
                        onPressed: () {
                          ShoppingListEntryPush entry = ShoppingListEntryPush();

                          String temp_uid =
                              Random().nextInt(1000000).toString();
                          ShoppingListEntry final_entry = ShoppingListEntry(
                              name: addedName.text,
                              checked: false,
                              uid: temp_uid,
                              local: true);

                          entry.checked = false;
                          entry.name = addedName.text;

                          if (showTags) {
                            // FIXME: entry.tags = selected_tag;
                          }

                          entries.add(final_entry);

                          entries = reorderShoppingListEntries(entries, filter);

                          getIt<ListRequestCacher>()
                              .insert_cached_entry(self, final_entry);
                          _key.currentState!.insertItem(
                              entries.indexOf(final_entry),
                              duration: const Duration(milliseconds: 300));
                          dirty = true;
                          pbc.list_entry_add(self, entry).then((v) {
                            setState(() {});
                          });
                        },
                        child: const Icon(Icons.add))
                  ],
                )
              ]))
            ])));
  }
}
