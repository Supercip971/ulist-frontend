import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ulist/list.dart';
import 'package:ulist/utils.dart';

class DummyListEntry extends StatefulWidget {
  const DummyListEntry(
      {super.key,
      required this.id,
      required this.entry,
      this.dummy = false,
      this.onChanged = null});

  final void Function(ShoppingListEntry entry, int id, bool slide)? onChanged;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final bool dummy;
  final int id;
  final ShoppingListEntry entry;

  @override
  State<DummyListEntry> createState() => _DummyListEntry();
}

class _DummyListEntry extends State<DummyListEntry>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  Animation<double>? _FadeAnimation;
  @override
  void initState() {
    super.initState();

//    _controller!.repeat(reverse: true);
  }

  @override
  void dispose() {
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
          color: Colors.grey.shade400,
        );

    TextStyle icon_style = Theme.of(context).textTheme.bodyLarge!.copyWith(
          overflow: TextOverflow.ellipsis,
          fontFamily: "MaterialIcons",
        );

    TextStyle checked_style = default_style.copyWith(
        decoration: TextDecoration.lineThrough, color: Colors.grey.shade600);

    last_value = widget.entry.checked;

    return Material(
        child: Material(
            color: Theme.of(context).colorScheme.surface,
            type: MaterialType.card,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            elevation: (this.widget.entry.checked ? 0 : 2),
            child: pad(Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Checkbox(
                  value: widget.entry.checked,
                  onChanged: (value) {},
                ),
                Flexible(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                          child: Text(widget.entry.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: ((widget.entry.checked)
                                  ? checked_style
                                  : default_style))),
                      Text("user")
                    ])),
              ],
            ))));
  }
}