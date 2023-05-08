import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ulist/pages/login_page.dart';
import 'package:ulist/pocket_base.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:ulist/utils.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AccountPage> createState() => _AccountPage();
}

class _AccountPage extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();

  var currentError = "";
  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();
    var user = pbc.current_user();

    var username = user!.name;
    var mail = user!.email;

    var pro = user.pro ? "Yes" : "No";

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
            key: _formKey,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,

                    // USERNAME
                    children: [
                      pad(
                        Text("User: $username"),
                      ),
                      pad(
                        Text("Mail: $mail"),
                      ),
                      pad(Text("Has pro ?: $pro")),
                      pad(Center(
                          child: Column(children: [
                        pad(ElevatedButton(
                          onPressed: () {
                            var res = pbc.logout().then((value) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage(
                                          title: "Login",
                                          afterRegister: true)));
                            }).catchError((e) {
                              setState(() =>
                                  currentError = deobfuscateError(e.response));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Logout failed: ' +
                                        e.response['message'].toString())),
                              );
                            });
                          },
                          child: const Text('Logout'),
                        ))
                      ])))
                    ]))));
  }
}
