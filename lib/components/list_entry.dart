import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ulist/list.dart';
import 'package:ulist/utils.dart';

class ListEntry extends StatefulWidget {
  const ListEntry(
      {super.key,
      required this.id,
      required this.entry,
      this.onChanged = null});

  final void Function(ShoppingListEntry entry, int id, bool slide)? onChanged;
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

class AnimatedCheckIcon extends AnimatedWidget {
  const AnimatedCheckIcon({super.key, required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: animation.value,
        width: animation.value,
        child: const FlutterLogo(),
      ),
    );
  }
}

class _ListEntry extends State<ListEntry> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

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
        );

    TextStyle icon_style = Theme.of(context).textTheme.bodyLarge!.copyWith(
          overflow: TextOverflow.ellipsis,
          fontFamily: "MaterialIcons",
        );

    TextStyle checked_style = default_style.copyWith(
        decoration: TextDecoration.lineThrough, color: Colors.grey);

    last_value = widget.entry.checked;

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
                widget.onChanged!(widget.entry, widget.id, true);
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
                child: pad(Row(
                  mainAxisSize: MainAxisSize.max,
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
                          widget.onChanged!(widget.entry, widget.id, false);
                        }
                      },
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
                )))));
  }
}
