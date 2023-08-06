import 'package:flutter/material.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/pages/list_properties.dart';
import 'package:cutelist/pages/popups/invite-after.dart';
import 'package:cutelist/pages/popups/invite.dart';
import 'package:cutelist/utils.dart';

class ListTagButton extends StatefulWidget {
  ListTagButton(
      {Key? key,
      required this.name,
      required this.callback,
      this.highlighted = false})
      : super(key: key);

  bool highlighted;
  final String name;
  final Function callback;
  @override
  State<ListTagButton> createState() => _ListTagButton();
}

class _ListTagButton extends State<ListTagButton> {
  @override
  Widget build(BuildContext context) {
    // random color from name
    Color color =
        Colors.primaries[widget.name.hashCode % Colors.primaries.length];
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        primary: color,
        side: BorderSide(
            color: color.withAlpha(widget.highlighted ? 200 : 120), width: 1),
        backgroundColor: color.withAlpha(widget.highlighted ? 255 : 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      onPressed: () => widget.callback(),
      child: Text(widget.name,
          style: TextStyle(
              color: widget.highlighted ? Colors.white : Colors.black,
              fontSize: 12)),
    );
  }
}
