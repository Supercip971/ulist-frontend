import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cutelist/components/list_tag.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/services.dart';
import 'package:cutelist/settings.dart';
import 'package:cutelist/utils.dart';

class ListEntry extends StatefulWidget {
  const ListEntry(
      {super.key,
      required this.id,
      required this.entry,
      this.onChanged = null});

  final void Function(
      ShoppingListEntry entry, int id, bool slide, bool removed)? onChanged;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final int id;
  final ShoppingListEntry entry;

  @override
  State<ListEntry> createState() => _ListEntry();
}

class _ListEntry extends State<ListEntry> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  var set = getIt<SettingsManager>();

  StreamSubscription<dynamic>? settings_sub;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    settings_sub = set.settingsUpdated.listen((event) {
      setState(() {});
    });

//    _controller!.repeat(reverse: true);
  }

  @override
  void dispose() {
    if (settings_sub != null) {
      settings_sub!.cancel();
      settings_sub = null;
    }
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  double drag_factor = 0.0;
  bool left = false;
  bool last_value = false;
  bool popped = false;

  @override
  Widget build(BuildContext context) {
    TextStyle default_style = Theme.of(context).textTheme.bodyLarge!.copyWith(
          overflow: TextOverflow.ellipsis,
        );

    TextStyle icon_style = Theme.of(context).textTheme.bodyLarge!.copyWith(
          overflow: TextOverflow.ellipsis,
          fontFamily: "MaterialIcons",
        );

    TextStyle checked_style = default_style.copyWith(
        decoration: TextDecoration.lineThrough, color: Colors.grey);

    last_value = widget.entry.checked;

    List<String> tags = widget.entry.tags;
    List<Widget> tags_widgets = [];
    for (int i = 0; i < tags.length; i++) {
      tags_widgets.add(Padding(
        padding: EdgeInsets.only(right: 4),
        child: ListTagButton(
          name: tags[i],
          callback: () {
            setState(() {});
          },
        ),
      ));
    }

    return Material(
        child: Dismissible(
            dismissThresholds: {
          DismissDirection.startToEnd: 0.3,
          DismissDirection.endToStart: 0.3
        },
            background: Material(
                borderRadius: BorderRadius.circular(8),
                child: padx(Row(
                  mainAxisAlignment:
                      (left) ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    padx(
                        factor: drag_factor * 8.0,
                        ScaleTransition(
                            scale: Tween(begin: 0.5, end: 1.5).animate(
                                CurvedAnimation(
                                    parent: _controller!,
                                    curve: Curves.elasticOut)),
                            child: Material(
                              borderRadius: BorderRadius.circular(64),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(min(drag_factor * 3.0, 1.0)),
                              child: pad(
                                  Icon(!last_value ? Icons.check : Icons.close,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                  factor: 0.2),
                            )))
                  ],
                ))),
            onUpdate: (details) {
              setState(() {
                if (details.progress >= 0.3 && popped == false) {
                  popped = true;
                  _controller!.forward(from: 0.0);
                } else if (details.progress < 0.3 && popped == true) {
                  popped = false;
                  _controller!.reverse(from: 1.0);
                }
                drag_factor = details.progress;
                left = details.direction == DismissDirection.endToStart;
              });
            },
            confirmDismiss: (direction) async {
              setState(() {
                widget.entry.checked = !widget.entry.checked;

                //   upload_change(place);
              });
              if (widget.onChanged != null) {
                widget.onChanged!(widget.entry, widget.id, true, false);
              }
              return true;
            },
            key: Key(widget.id.toString() +
                widget.entry.uid +
                widget.entry.checked.toString()),
            child: Material(
                color: Theme.of(context).colorScheme.surface,
                type: MaterialType.card,
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                elevation: (widget.entry.checked) ? 0 : 2,
                child: pad(
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // :eyes: for later
                            //   RawMaterialButton(
                            //     onPressed: () {},
                            //     elevation: 2.0,
                            //     fillColor: Theme.of(context).colorScheme.surface,
                            //     child: Text("🍺", style: icon_style),
                            //     padding: EdgeInsets.all(10.0),
                            //     shape: CircleBorder(),
                            //   ),
                            Checkbox(
                              value: widget.entry.checked,
                              onChanged: (value) {
                                setState(() {
                                  widget.entry.checked = !widget.entry.checked;
                                  //   upload_change(place);
                                });
                                if (widget.onChanged != null) {
                                  widget.onChanged!(
                                      widget.entry, widget.id, false, false);
                                }
                              },
                            ),
                            Flexible(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Container(
                                      child: Text(widget.entry.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: ((widget.entry.checked)
                                              ? checked_style
                                              : default_style))),
                                  Text(widget.entry.addedBy)
                                ])),
                          ],
                        ),
                        Spacer(),
                        tags_widgets.length > 0
                            ? Row(
                                children: tags_widgets,
                              )
                            : Container(),
                        (PopupMenuButton(onSelected: (String v) {
                          if (v == "remove") {
                            widget.onChanged!(
                                widget.entry, widget.id, false, true);
                          }
                        }, itemBuilder: (BuildContext context) {
                          var result = <PopupMenuEntry<String>>[];

                          result.add(PopupMenuItem<String>(
                            value: "tag",
                            child: Row(children: [
                              padx(Icon(Icons.brush), factor: 0.2),
                              padx(Text("tag"), factor: 0.2)
                            ]),
                          ));

                          result.add(PopupMenuItem<String>(
                            value: "rename",
                            child: Row(children: [
                              padx(Icon(Icons.edit), factor: 0.2),
                              padx(Text("rename"), factor: 0.2)
                            ]),
                          ));

                          result.add(PopupMenuItem<String>(
                            value: "remove",
                            child: Row(children: [
                              padx(Icon(Icons.delete), factor: 0.2),
                              padx(Text("remove"), factor: 0.2)
                            ]),
                          ));
                          return result;
                        }))
                      ],
                    ),
                    factor: set.compactMode ? 0.5 : 1.0))));
  }
}
