import 'package:flutter/material.dart';
import 'package:cutelist/pages/account_page.dart';
import 'package:cutelist/utils.dart';

class NewListResult {
  String name = "";

  bool is_readonly_by_default = false;
}

Future<NewListResult?> showNewListSettings(BuildContext context) async {
  TextStyle style = Theme.of(context).textTheme.headlineLarge!;

  final TextEditingController _NameController = TextEditingController();

  return await showDialog<NewListResult>(
    context: context,
    builder: (context) => SizedBox(
        height: 500,
        child: Dialog(
            child: pad(Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              pad(
                Text("Create a new list",
                    style: style.apply(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer)),
              )
            ]),
            pad(Column(children: [
              pady(TextField(
                controller: _NameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.list),
                  labelText: 'List name',
                  hintText: 'my super cool family list!',
                  border: OutlineInputBorder(),
                ),
              )),
              Row(children: [
                Spacer(),
                pad(TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: padx(Text(
                      "Cancel",
                    )))),
                FilledButton(
                    onPressed: () => {
                          Navigator.pop(
                              context,
                              NewListResult()
                                ..name = _NameController.text
                                ..is_readonly_by_default = false)
                        },
                    child: Row(
                      children: [Icon(Icons.check), Text("Create")],
                    )),
              ])
            ])),
          ],
        )))),
  );
}
