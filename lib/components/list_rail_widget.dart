import 'package:flutter/material.dart';
import 'package:cutelist/components/list_lists.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/main.dart';
import 'package:cutelist/pages/list_properties.dart';
import 'package:cutelist/pages/login_page.dart';
import 'package:cutelist/pages/popups/invite-after.dart';
import 'package:cutelist/pages/popups/invite.dart';
import 'package:cutelist/pages/popups/join_list.dart';
import 'package:cutelist/pages/popups/new_list.dart';
import 'package:cutelist/pages/register_page.dart';
import 'package:cutelist/pocket_base.dart';
import 'package:cutelist/services.dart';
import 'package:cutelist/utils.dart';

class ListRailWidget extends StatefulWidget {
  const ListRailWidget({Key? key, required this.onSelect}) : super(key: key);

  final Function onSelect;
  @override
  State<ListRailWidget> createState() => _ListRailWidget();
}

class _ListRailWidget extends State<ListRailWidget> {
  Future<String> init_loader() async {
//    super.initState();

    return Future.delayed(Duration(milliseconds: 16), () {
      if (getIt<PocketBaseController>().loaded) {
        return getIt<PocketBaseController>().current_user()!.email;
      }

      return getIt<PocketBaseController>().init().then((value) {
        if (!getIt<PocketBaseController>().logged_in) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const LoginPage(title: 'cutelist - login')),
          ).then((value) {
            setState(() {});
          });

          return "unlogged";
        }
        return getIt<PocketBaseController>().current_user()!.email;
      });
    });
  }

  List<ShoppingListRight> right_lists = [];
  List<ShoppingList> lists = [];
  Future<List<ShoppingList>> init_lists() async {
    right_lists = [];
    right_lists =
        await getIt<PocketBaseController>().current_user_lists_right();

    lists = [];
    for (var l in right_lists) {
      lists.add(await getIt<PocketBaseController>().get_list(l.shoppingListId));
    }
    return lists;
  }

  Widget listListBuilder(BuildContext context, AsyncSnapshot snapshot) {
    return listListWidget(context, snapshot, null);
  }

  Widget get_lists(BuildContext context) {
    return Column(children: [
      FutureBuilder<List<ShoppingList>>(
          future: init_lists(), builder: listListBuilder),
    ]);
  }

  MenuSelect? selectedMenu;

  void ShowListCreate() {
    var pbc = getIt<PocketBaseController>();
    showNewListSettings(context).then(
      (value) => {
        if (value != null)
          {
            pbc.list_entry_create(value.name).then((_) => {
                  setState(() {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("List created")));
                  })
                })
          }
      },
    );
  }

  Future<void> ShowListJoin() async {
    var pbc = getIt<PocketBaseController>();
    await showJoinListSettings(context);
  }

  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();

    return SingleChildScrollView(
        child: pady(Center(
            child: FutureBuilder<String>(
                future: init_loader(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  List<Widget> children = [];
                  if (snapshot.hasData || snapshot.hasError) {
                    if (pbc.logged_in) {
                      children = [
                        get_lists(context),
                        padx(Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              padx(
                                  TextButton(
                                      onPressed: () => {
                                            ShowListJoin().then(
                                              (value) {
                                                setState(() {});
                                              },
                                            )
                                          },
                                      child: (Row(children: [
                                        padx(const Icon(Icons.share)),
                                        const Text("Join a new list")
                                      ]))),
                                  factor: 2.0),
                              padx(
                                  TextButton(
                                      onPressed: () => {ShowListCreate()},
                                      child: (Row(children: [
                                        padx(const Icon(Icons.add)),
                                        const Text("Create a new list")
                                      ]))),
                                  factor: 2.0)
                            ]))
                      ];
                    } else {
                      children = [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            pad(ElevatedButton(
                                onPressed: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(
                                                    title: 'U list - login')),
                                      ).then((value) => {setState(() {})})
                                    },
                                child: Text("Login"))),
                            pad(ElevatedButton(
                                onPressed: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterPage(
                                                    title:
                                                        'U list - register')),
                                      ).then((value) => {setState(() {})})
                                    },
                                child: Text("Register")))
                          ],
                        )
                      ];
                    }
                    //     children = [
                    //       Center(child: pad(Text("Loaded ! ${snapshot.data}"))),
                    //     ];
                  } else {
                    children = [
                      Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        pad(CircularProgressIndicator()),
                        pad(Text("Loading")),
                        pad(Text("Connecting account..."))
                      ]))
                    ];
                  }
                  return Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min, children: children));
                }))));
  }
}
