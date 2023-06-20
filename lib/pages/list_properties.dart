import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ulist/components/list_entry.dart';
import 'package:ulist/components/list_properties.dart';
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
    setState(() {
      loading = false;
      dirty = false;
    });
    return true;
  }

  Widget listUserEntry(BuildContext context, ListUser user) {
    return ListTile(
      title: Row(children: [
        Text(user.user.name),
        user.is_owner
            ? padx(Text(
                "(owner)",
                style: Theme.of(context).textTheme.bodySmall,
              ))
            : user.is_administrator
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
                      pady(Text(user.user.name,
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

  Widget listUsersPanel(BuildContext context) {
    List<ListUser> users = [
      ListUser(user: const User(name: "david"), is_administrator: true),
      ListUser(user: const User(name: "Bob"), is_administrator: false),
      ListUser(
          user: const User(name: "Mom"),
          is_administrator: false,
          is_owner: true),
    ];

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
            actions: [ListPropertiesBar(entry: self)]),
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
