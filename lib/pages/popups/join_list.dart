import 'package:flutter/material.dart';
import 'package:ulist/pages/account_page.dart';
import 'package:ulist/utils.dart';

class JoinListResult {
  String name = "";

  bool is_readonly_by_default = false;
}

Future<JoinListResult?> showJoinListSettings(BuildContext context) async {
  TextStyle style = Theme.of(context).textTheme.headlineLarge!;

  final TextEditingController _NameController = TextEditingController();

  return await showDialog<JoinListResult>(
    context: context,
    builder: (context) => SizedBox(
        height: 500,
        child: Dialog(
            child: pad(Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              pad(
                Text("Join a new list",
                    style: style.apply(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer)),
              )
            ]),
            pad(Text(
                "If someone want to share a list with you, you can ask them to create an invite code. Paste it here to join the list.")),
            pad(Column(children: [
              pady(TextField(
                controller: _NameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.code),
                  labelText: 'Invite code',
                  hintText: 'ea10e183917...',
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
                    onPressed: () => {},
                    child: Row(
                      children: [Icon(Icons.arrow_circle_right), Text("Join")],
                    )),
              ])
            ])),
          ],
        )))),
  );
}
