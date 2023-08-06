import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:cutelist/pages/register_page.dart';
import 'package:cutelist/pocket_base.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:cutelist/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title, this.afterRegister = false});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final bool afterRegister;

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  String server_status = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController =
      TextEditingController(text: (kDebugMode) ? "supercyp971@gmail.com" : "");
  TextEditingController passwordController =
      TextEditingController(text: (kDebugMode) ? "test123123" : "");

  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();

    pbc.status().then((value) {
      if (value!.code == 200) {
        server_status = "";
      } else {
        setState(() {
          server_status =
              "Error server: " + value!.code.toString() + value!.message;
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        if (error is ClientException) {
          server_status = "Error server: " + error.originalError.toString();
          return;
        }
        server_status = "Error server: " + error.toString();
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (server_status != "")
                  ? Text((server_status),
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold))
                  : Container(),
              (widget.afterRegister)
                  ? Text(
                      "You're account has successfully been registered. Please login.")
                  : Text("Please login."),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email",
                      icon: Icon(Icons.email)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                      icon: Icon(Icons.lock)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              (pbc.logged_in)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16.0),
                      child: Center(
                        child:
                            Text("Logged in as " + pbc.current_user()!.email),
                      ),
                    )
                  : (Container()),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: Column(children: [
                    pad(ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var res = pbc
                              .login(
                                  emailController.text, passwordController.text)
                              .then((value) {
                            Navigator.pop(context);
                          }).catchError((e) {
                            try {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Login failed: ' +
                                        e.response["message"])),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Login failed: ' + e.toString())),
                              );
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                      child: const Text('Login'),
                    )),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        pad(TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterPage(title: "Register")));
                          },
                          child: const Text('Register'),
                        )),
                        pad(TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        )),
                      ],
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
