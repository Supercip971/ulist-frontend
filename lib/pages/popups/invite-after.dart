import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cutelist/list.dart';
import 'package:cutelist/pages/account_page.dart';
import 'package:cutelist/pocket_base.dart';
import 'package:cutelist/services.dart';
import 'package:cutelist/utils.dart';
import 'package:share_plus/share_plus.dart';

class ListInviteResult {
  String code = "";
}

Future<bool?> showListInvitationCode(
    BuildContext context, String code, ShoppingList target) async {
  TextStyle style = Theme.of(context).textTheme.headlineLarge!;

  final TextEditingController _NameController = TextEditingController();

  return await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) => SizedBox(
                height: 500,
                child: Dialog(
                    child:
                        pad(Column(mainAxisSize: MainAxisSize.min, children: [
                  pad(Row(children: [
                    Flexible(
                        child: Text("Successfully created an invitation code !",
                            style: style.apply(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer))),
                  ])),
                  pad(Text("The invite code is:")),
                  Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: pad(SelectableText(code))),
                  pady(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        padx(
                          FilledButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: code));
                              },
                              child: const Row(
                                children: [Icon(Icons.copy), Text("Copy")],
                              )),
                        ),
                        padx(
                          FilledButton(
                              onPressed: () {
                                Share.share(code);
                              },
                              child: const Row(
                                children: [Icon(Icons.share), Text("Share")],
                              )),
                        )
                      ],
                    ),
                  ),
                  pad(Column(
                    children: [
                      const Row(children: [
                        Spacer(),
                      ]),
                      pad(Column(children: [
                        Row(children: [
                          const Spacer(),
                          padx(TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: padx(const Text(
                                "Close",
                              )))),
                        ])
                      ])),
                    ],
                  ))
                ])))));
      });
}
