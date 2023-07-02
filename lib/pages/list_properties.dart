import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ulist/components/list_entry.dart';
import 'package:ulist/components/list_properties.dart';
import 'package:ulist/components/list_tag.dart';
import 'package:ulist/list.dart';
import 'package:ulist/listRequestCacher.dart';
import 'package:ulist/pages/dummy_list_page.dart';
import 'package:ulist/pages/register_page.dart';
import 'package:ulist/pocket_base.dart';
import 'package:ulist/user.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:ulist/utils.dart';

class ListPropertiesPage extends StatefulWidget {
  ListPropertiesPage({super.key, required this.id});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String id;
  final OverlayEntry? overlay_entry = null;

  @override
  State<ListPropertiesPage> createState() => _ListPropertiesPage();
}

class _ListPropertiesPage extends State<ListPropertiesPage> {
  ShoppingList self = ShoppingList();
  ShoppingListInformation props = ShoppingListInformation();

  bool dirty = true;
  bool loading = true;

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
    self = await getIt<PocketBaseController>().get_list(self.uid);
    var res = await getIt<PocketBaseController>().get_list_props(self.uid);
    if (res == null) {
      throw Exception("Could not load list properties");
    }

    props = res;

    setState(() {
      loading = false;
      dirty = false;
    });
    return true;
  }

  Widget listUserEntry(BuildContext context, ShoppingListPropsUser user) {
    return ListTile(
      title: Row(children: [
        Text(user.name),
        user.owner
            ? padx(Text(
                "(owner)",
                style: Theme.of(context).textTheme.bodySmall,
              ))
            : user.owner
                ? padx(Text(
                    "(administrator)",
                    style: Theme.of(context).textTheme.bodySmall,
                  ))
                : Spacer()
      ]),
      leading: Icon(Icons.person),
      onTap: () => {
        showDialog<void>(
            context: context,
            builder: (context) => SizedBox(
                height: 600,
                child: Dialog(
                  child: pad(Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      pady(Text(user.name,
                          style: Theme.of(context).textTheme.titleMedium)),

                      // -----

                      Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface,
                          child: pad(Column(children: [
                            TextButton.icon(
                              icon: const Icon(Icons.shield),
                              onPressed: () => {
                                Navigator.pop(context),
                                setState(() {}),
                              },
                              label: const Text("Make user administrator"),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.person_remove),
                              onPressed: () => {
                                Navigator.pop(context),
                                setState(() {}),
                              },
                              label: const Text("Remove user from list"),
                            ),
                          ]))),

                      // -----
                      pady(TextButton(
                        onPressed: () => {Navigator.pop(context)},
                        child: Text("Close"),
                      )),
                    ],
                  )),
                )))
      },
    );
  }

  Widget listPropertiesPanel(BuildContext context) {
    ButtonStyle st = ButtonStyle(
      foregroundColor:
          MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.error),
    );
    List<Widget> actions = [
      TextButton.icon(
        onPressed: () {},
        label: Text("Rename"),
        icon: Icon(Icons.edit),
      ),
      TextButton.icon(
        onPressed: () {},
        label: Text("Share"),
        icon: Icon(Icons.share),
      ),
      TextButton.icon(
          onPressed: () {},
          label: Text("Quit"),
          icon: Icon(Icons.close),
          style: st),
      TextButton.icon(
          onPressed: () {},
          label: Text("Delete list"),
          icon: Icon(Icons.delete),
          style: st),
    ];

    List<Widget> f2 = [];
    for (var action in actions) {
      f2.add(padx(Align(alignment: Alignment.centerLeft, child: action)));
    }
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: pady(Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: f2)),
    );
  }

  Widget listUsersPanel(BuildContext context) {
    List<ShoppingListPropsUser> users = [
    ];

	for (var user in props.users) {
		users.add(user);
	}

    List<Widget> usersWidgets = [];

    for (var user in users) {
      usersWidgets.add(listUserEntry(context, user));
    }
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: pady(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: usersWidgets,
      )),
    );
  }

  Widget listTags(BuildContext context) {

	  List<Widget> listTagsWidgets = [];
	  for(var tag in self.tags) {
		  listTagsWidgets.add(pady(ListTagButton(name: tag, callback: () {}), factor: 0.2)); 
	  }


	  if(listTagsWidgets.length == 0) {
		  return Text("No tags");
	  }
return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: pady(Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: listTagsWidgets)),
    );
	  return Column(children: listTagsWidgets);

  }
 
  Widget propertiesWidget(BuildContext context) {
    return SingleChildScrollView(
        primary: true,
        child: pad((Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              pad(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    pady(Text("List properties",
                        style: Theme.of(context).textTheme.headlineSmall)),
                    listPropertiesPanel(context),
				    pady(Text("List tags",
                        style: Theme.of(context).textTheme.headlineSmall)),
					listTags(context),
                    
                    pady(Text("List shares",
                        style: Theme.of(context).textTheme.headlineSmall)),
                    pady(Text("List users",
                        style: Theme.of(context).textTheme.headlineSmall)),
                    listUsersPanel(context),
                  ])),
            ]))));
  }

  @override
  Widget build(BuildContext context) {
    self.uid = widget.id;

    var pbc = getIt<PocketBaseController>();

    return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Text(self.name.toString() + " - properties",
                style: Theme.of(context).textTheme.headlineSmall),
            if (loading) padx(const CircularProgressIndicator(), factor: 3.0)
          ]),
        ),
        body: Center(
            child: FutureBuilder<bool>(
          future: load_data(false),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return propertiesWidget(context);
            } else if (snapshot.hasError) {
              print(snapshot.stackTrace);
              return Text("${snapshot.error}");
            }

            return pad(CircularProgressIndicator());
          },
        )));
  }
}
