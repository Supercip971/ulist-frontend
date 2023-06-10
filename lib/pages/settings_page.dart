import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ulist/components/list_entry_dummy.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/register_page.dart';
import 'package:ulist/pocket_base.dart';
import 'package:ulist/settings.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:ulist/utils.dart';

class SettingsCompactView extends StatefulWidget {
  const SettingsCompactView({super.key, required this.height});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final double height;

  @override
  State<SettingsCompactView> createState() => _SettingsCompactView();
}

class _SettingsCompactView extends State<SettingsCompactView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: pad(Column(children: [
      DummyListEntry(
          id: 0,
          entry: ShoppingListEntry(
            name: "Dummy entry",
            checked: false,
            local: true,
          ),
          forceMode: widget.height),
      DummyListEntry(
          id: 1,
          entry: ShoppingListEntry(
            name: "Dummy entry",
            checked: false,
            local: true,
          ),
          forceMode: widget.height),
      DummyListEntry(
          id: 2,
          entry: ShoppingListEntry(
            name: "Dummy entry",
            checked: false,
            local: true,
          ),
          forceMode: widget.height),
      DummyListEntry(
          id: 3,
          entry: ShoppingListEntry(
            name: "Dummy entry",
            checked: false,
            local: true,
          ),
          forceMode: widget.height),
    ])));
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();
    var set = getIt<SettingsManager>();

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
            child: pady(padx(Column(
          children: [
            Text("Settings", style: Theme.of(context).textTheme.titleLarge),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Column(children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => {
                                setState(() {
                                  set.settings.compactMode = false;
                                  set.syncSettings();
                                })
                              },
                          child: pad(Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                border: Border.all(
                                  color: (!set.compactMode
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent),
                                  width: 2,
                                ),
                              ),
                              child: SettingsCompactView(height: 1.0)))),
                    ),
                    Expanded(
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => {
                                setState(() {
                                  set.settings.compactMode = true;
                                  set.syncSettings();
                                })
                              },
                          child: pad(Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                border: Border.all(
                                  color: (set.compactMode
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent),
                                  width: 2,
                                ),
                              ),
                              child: SettingsCompactView(height: 0.5)))),
                    )
                  ],
                ),
                // COMPACT MODE
                pady(
                  Material(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      surfaceTintColor:
                          Theme.of(context).colorScheme.surfaceTint,
                      child: pad(
                          Column(children: [
                            pady(
                                Row(
                                  children: [
                                    Text("Compact mode",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    Spacer(),
                                    Switch(
                                        value: set.compactMode,
                                        onChanged: (v) => {
                                              setState(() {
                                                set.settings.compactMode = v;

                                                set.syncSettings();
                                              })
                                            })
                                  ],
                                ),
                                factor: 0.5),
                            Text(
                                "Select it if you want to see more items on the screen.")
                          ]),
                          factor: 1)),
                ),
              ]),
            ),
            //
            // DARK MODE
            //
            Column(
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(children: [
                    pad(Row(
                      children: [
                        Expanded(
                            child: IconButton(
                                color: set.settings.darkMode
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                onPressed: () => {
                                      setState(() {
                                        set.settings.darkMode = true;

                                        set.syncSettings();
                                      })
                                    },
                                icon: Icon(Icons.dark_mode, size: 64.0))),
                        Expanded(
                            child: IconButton(
                                color: !set.settings.darkMode
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                onPressed: () => {
                                      setState(() {
                                        set.settings.darkMode = false;

                                        set.syncSettings();
                                      })
                                    },
                                icon: Icon(Icons.light_mode, size: 64.0))),
                      ],
                    )),
                    // COMPACT MODE
                    pady(
                      Material(
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          surfaceTintColor:
                              Theme.of(context).colorScheme.surfaceTint,
                          child: pad(
                              Column(children: [
                                pady(
                                    Row(
                                      children: [
                                        Text("Dark/Light mode",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        Spacer(),
                                        Switch(
                                            value: set.darkMode,
                                            onChanged: (v) => {
                                                  setState(() {
                                                    set.settings.darkMode = v;

                                                    set.syncSettings();
                                                  })
                                                })
                                      ],
                                    ),
                                    factor: 0.5),
                                Text(
                                    "Select if you want to change the overall theme.")
                              ]),
                              factor: 1)),
                    ),
                  ]),
                ),
              ],
            ),
          ],
        )))));
  }
}
