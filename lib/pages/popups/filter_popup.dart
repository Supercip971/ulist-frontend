import 'package:flutter/material.dart';
import 'package:ulist/components/list_tag.dart';
import 'package:ulist/list.dart';
import 'package:ulist/pages/account_page.dart';
import 'package:ulist/pocket_base.dart';
import 'package:ulist/services.dart';
import 'package:ulist/utils.dart';

class FilterResult {
  String? result = "";
}

Future<FilterResult?> showFilterSelection(
    BuildContext context, ShoppingList list) async {
  TextStyle style = Theme.of(context).textTheme.headlineLarge!;

  final TextEditingController _NameController = TextEditingController();

  return await showDialog<FilterResult?>(
      context: context,
      builder: (context) {
        String results = "";

        List<Widget> options = [];

        list.tags.forEach((entry) {
          FilterResult res = FilterResult();
          res.result = entry;
          options.add(pady(ListTagButton(
              name: entry,
              callback: () {
                Navigator.pop(context, res);
              }), factor: 0.5));
        });
        // values
        return StatefulBuilder(
            builder: (context, setState) => SizedBox(
                height: 500,
                child: Dialog(
                  child: pad(Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      pad(
                        Text("Filter by tag",
                            style: style.apply(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer)),
                      )
                    ]),
                    pad(Text("Filtering by a tag")),
					SingleChildScrollView(child: 
                    pad(Column(children: options)),
					),
                    Row(children: [
                      Spacer(),
                      padx(TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: padx(Text(
                            "Cancel",
                          )))),

                      (TextButton.icon(
                          onPressed: () {
                            var pbc = getIt<PocketBaseController>();

                            Navigator.pop(context);
                          },
						  icon: Icon(Icons.create),
                          label: 
                              Text("Create a new tag")
                          )),
                      (TextButton.icon(
                          onPressed: () {
                            var pbc = getIt<PocketBaseController>();

                            Navigator.pop(context);
                          },
						  icon: Icon(Icons.brush),
                          label: 
                              Text("Apply tags")
                            
                          )),
                    ])
                  ])),
                )));
      });
}
