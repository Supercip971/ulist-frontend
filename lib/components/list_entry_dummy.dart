import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cutelist/components/list_tag.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/services.dart';
import 'package:cutelist/settings.dart';
import 'package:cutelist/utils.dart';

class DummyListEntry extends StatefulWidget {
  const DummyListEntry(
      {super.key,
      required this.id,
      required this.entry,
      this.dummy = false,
      this.onChanged = null,
      this.forceMode = null});

  final void Function(ShoppingListEntry entry, int id, bool slide)? onChanged;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final bool dummy;
  final double? forceMode;
  final int id;
  final ShoppingListEntry entry;

  @override
  State<DummyListEntry> createState() => _DummyListEntry();
}

class _DummyListEntry extends State<DummyListEntry>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  var set = getIt<SettingsManager>();

  StreamSubscription<dynamic>? settings_sub;
  Animation<double>? _FadeAnimation;
  @override
  void initState() {
    super.initState();

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
          color: Colors.grey.shade400,
        );

    TextStyle icon_style = Theme.of(context).textTheme.bodyLarge!.copyWith(
          overflow: TextOverflow.ellipsis,
          fontFamily: "MaterialIcons",
        );

    TextStyle checked_style = default_style.copyWith(
        decoration: TextDecoration.lineThrough, color: Colors.grey.shade600);

    last_value = widget.entry.checked;

    List<String> tags = widget.entry.tags;
    List<Widget> tags_widgets = [];
    for (int i = 0; i < tags.length; i++) {
      tags_widgets.add(Padding(
        padding: EdgeInsets.only(right: 4),
        child: ListTagButton(
          name: tags[i],
          callback: () {},
        ),
      ));
    }
/*               child: pad(
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
						],),
						tags_widgets.length > 0 ?  Row(
							children: tags_widgets,
						)	 : Container(),
						
                      ],
                    ),
                    factor: set.compactMode ? 0.5 : 1.0))));
  }*/

    return Material(
        child: Material(
            color: Theme.of(context).colorScheme.surface,
            type: MaterialType.card,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            elevation: (this.widget.entry.checked ? 0 : 2),
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
                    ),
                    Spacer(),
                    tags_widgets.length > 0
                        ? Row(
                            children: tags_widgets,
                          )
                        : Container(),
                    (PopupMenuButton(itemBuilder: (BuildContext context) {
                      var result = <PopupMenuEntry<String>>[];
                      result.add(PopupMenuItem<String>(
                        value: "remove",
                        child: Text("remove"),
                      ));

                      return result;
                    }))
                  ],
                ),
                factor: (widget.forceMode != null
                    ? widget.forceMode!
                    : (set.compactMode ? 0.5 : 1.0)))));
  }
}
