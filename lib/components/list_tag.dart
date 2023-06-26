import 'package:flutter/material.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/list_properties.dart';
import 'package:ulist/pages/popups/invite-after.dart';
import 'package:ulist/pages/popups/invite.dart';
import 'package:ulist/utils.dart';

class ListTagButton extends StatefulWidget {
  const ListTagButton ({Key? key, required this.name, required this.callback}) : super(key: key);

  final String name;
  final Function callback;
  @override
  State<ListTagButton> createState() => _ListTagButton();
}

class _ListTagButton extends State<ListTagButton> {
  @override
  Widget build(BuildContext context) {
	  // random color from name
	  Color color = Colors.primaries[widget.name.hashCode % Colors.primaries.length];
	return OutlinedButton(
		style: OutlinedButton.styleFrom(
			padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),

			primary: color, 


			side: BorderSide(color: color.withAlpha(120), width: 1),
			backgroundColor: color.withAlpha(20),
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.all(Radius.circular(20)),
			),
		),
	
	  onPressed: () => widget.callback(),
	  child: Text(widget.name, style: TextStyle(color: Colors.black, fontSize: 12)),
	);
   
  }
}
