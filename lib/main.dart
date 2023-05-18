import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:ulist/components/list_lists.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/account_page.dart';
import 'package:ulist/pages/list_page.dart';
import 'package:ulist/pages/popups/home_properties.dart';
import 'package:ulist/pages/popups/new_list.dart';
import 'package:ulist/pages/register_page.dart';
import 'package:ulist/pocket_base.dart';
import 'package:ulist/utils.dart';

import 'services.dart';
import 'package:ulist/pages/login_page.dart';

void main() async {
  await setupServiceLocators();
  await getIt.allReady();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'U list',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.greenAccent, brightness: Brightness.dark),
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        useMaterial3: true,
        //    primarySwatch: Colors.blue,
      ),
      home: const HomeSelect(title: 'Ulist'),
    );
  }
}

class HomeSelect extends StatefulWidget {
  const HomeSelect({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomeSelect> createState() => HomeSelectState();
}

enum MenuSelect { menuAccount, menuSettings }

class HomeSelectState extends State<HomeSelect> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

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
                builder: (context) => const LoginPage(title: 'ULIST - login')),
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

  Widget get_lists(BuildContext context) {
    return Column(children: [
      FutureBuilder<List<ShoppingList>>(
          future: init_lists(), builder: listListWidget),
    ]);
  }

  MenuSelect? selectedMenu;

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();
    //ini();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title,
              style: Theme.of(context).textTheme.headlineMedium),
          actions: [
            padx(IconButton(
                onPressed: () => {showPropertiesAccount(context)},
                icon: Icon(Icons.account_circle)))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => {
            showNewListSettings(context).then(
              (value) => {
                if (value != null)
                  {
                    setState(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("List created")));
                    })
                  }
              },
            )
          },
          label: Text("Add list"),
          icon: Icon(Icons.add),
        ),
        body: Center(
            child: FutureBuilder<String>(
                future: init_loader(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData || snapshot.hasError) {
                    if (pbc.logged_in) {
                      children = [get_lists(context)];
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
                })));
  }
}

/*
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        elevation: 4,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}*/
