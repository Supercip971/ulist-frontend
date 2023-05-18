import 'package:flutter/material.dart';
import 'package:ulist/pages/account_page.dart';
import 'package:ulist/pages/login_page.dart';
import 'package:ulist/utils.dart';

Future showPropertiesAccount(BuildContext context) async {
  TextStyle style = Theme.of(context).textTheme.headlineLarge!;

  return await showDialog<void>(
    context: context,
    builder: (context) => SizedBox(
        height: 600,
        child: Dialog(
            child: pad(Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              pad(
                Text("Ulist",
                    style: style.apply(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer)),
              )
            ]),
            Card(
                elevation: 0.0,
                color: Theme.of(context).colorScheme.surface,
                child: pad(Column(children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AccountPage(title: 'ULIST - login')),
                        ).then((value) {});
                      },
                      child: pad(Row(
                        children: [
                          padx(Icon(
                            Icons.account_circle,
                          )),
                          padx(Text(
                            "Account",
                          ))
                        ],
                      ))),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AccountPage(title: 'ULIST - login')),
                        ).then((value) {});
                      },
                      child: pad(Row(
                        children: [
                          padx(Icon(
                            Icons.settings,
                          )),
                          padx(Text(
                            "Settings",
                          ))
                        ],
                      ))),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AccountPage(title: 'ULIST - login')),
                        ).then((value) {});
                      },
                      child: (pad(Row(
                        children: [
                          padx(Icon(
                            Icons.handshake,
                          )),
                          Flexible(
                              child: padx(Text(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            "Licenses and legal information",
                          )))
                        ],
                      )))),
                ]))),
            pad(
              Text("Thank you for using this app !"),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AccountPage(title: 'ULIST - login')),
                    ).then((value) {});
                  },
                  child: Text("source code"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AccountPage(title: 'ULIST - login')),
                    ).then((value) {});
                  },
                  child: Text("changelog"),
                )
              ],
            )
          ],
        )))),
  );
}
