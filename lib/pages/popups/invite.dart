import 'package:flutter/material.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/pages/account_page.dart';
import 'package:cutelist/pocket_base.dart';
import 'package:cutelist/services.dart';
import 'package:cutelist/utils.dart';

class ListInviteResult {
  String code = "";
}

Future<ListInviteResult?> showListInvite(
    BuildContext context, ShoppingList target) async {
  TextStyle style = Theme.of(context).textTheme.headlineLarge!;

  final TextEditingController _NameController = TextEditingController();

  return await showDialog<ListInviteResult>(
      context: context,
      builder: (context) {
        String error_code = "";

        DateTime invalidation_date = DateTime.now().add(Duration(days: 1));

        Duration invalidation_diff =
            invalidation_date.difference(DateTime.now());
        // values
        return StatefulBuilder(
          builder: (context, setState) => SizedBox(
              height: 500,
              child: Dialog(
                  child: pad(Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    pad(
                      Text("Invite new users",
                          style: style.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer)),
                    )
                  ]),
                  pad(Text("If you want to add new users to this list: '" +
                      target.name +
                      "' you can create an invite code. Share it with them and they will be able to join the list.")),
                  padx(Text(error_code, style: TextStyle(color: Colors.red))),
                  pad(Column(children: [
                    (Text(
                        "The invitation will be invalid after some time. So that an code isn't valid forever. Users who joined the list will not be affected by this.")),
                    (Text("The invitation code will be invalidated in " +
                        invalidation_diff.inDays.toString() +
                        " days and " +
                        (invalidation_diff.inHours -
                                invalidation_diff.inDays * 24)
                            .toString() +
                        " hours.")),
                    pady(
                      OutlinedButton.icon(
                          onPressed: () => {
                                showDatePicker(
                                        context: context,
                                        initialDate: invalidation_date,
                                        firstDate: DateTime.now()
                                            .add(Duration(days: 1)),
                                        lastDate: DateTime.now()
                                            .add(Duration(days: 8)))
                                    .then((value) {
                                  setState(() {
                                    if (value == null) return;
                                    invalidation_date = value;
                                    invalidation_diff = invalidation_date
                                        .difference(DateTime.now());
                                  });
                                })
                              },
                          icon: Icon(Icons.date_range),
                          label: Text("Set invite invalidation date")),
                    ),
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
                          onPressed: () {
                            var pbc = getIt<PocketBaseController>();
                            pbc
                                .list_entry_create_invite(
                                    target, invalidation_date)
                                .then((value) {
                              print(value);
                              Navigator.pop(
                                  context, ListInviteResult()..code = value);
                            });
                          },
                          child: Row(
                            children: [Icon(Icons.share), Text("Create")],
                          )),
                    ])
                  ])),
                ],
              )))),
        );
      });
}
