import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ulist/pages/register_page.dart';
import 'package:ulist/pocket_base.dart';
import 'package:ulist/settings.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:ulist/utils.dart';

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
        body: pady(padx(
            Column(
              children: [
                Text("Settings", style: Theme.of(context).textTheme.titleLarge),
                Column(
                  children: [
                    // COMPACT MODE
                    pady(
                      Material(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          surfaceTintColor:
                              Theme.of(context).colorScheme.surfaceTint,
                          child: pad(
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                                        set.settings
                                                            .compactMode = v;

                                                        set.syncSettings();
                                                      })
                                                    })
                                          ],
                                        ),
                                        factor: 0.5),
                                    Text(
                                        "Select if you want a more compact version of the list."),
                                    Text(
                                        "Usefull if you want to see more items on the screen.")
                                  ]),
                              factor: 1)),
                    ),
                    pady(
                      Material(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          surfaceTintColor:
                              Theme.of(context).colorScheme.surfaceTint,
                          child: pad(
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    pady(
                                        Row(
                                          children: [
                                            Text("Dark theme",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium),
                                            Spacer(),
                                            Switch(
                                                value: set.darkMode,
                                                onChanged: (v) => {
                                                      setState(() {
                                                        set.settings.darkMode =
                                                            v;

                                                        set.syncSettings();
                                                      })
                                                    })
                                          ],
                                        ),
                                        factor: 0.5),
                                    Text(
                                        "Select if you want a darker version of the app."),
                                  ]),
                              factor: 1)),
                    )
                  ],
                ),
              ],
            ),
            factor: 1.5)));
  }
}
