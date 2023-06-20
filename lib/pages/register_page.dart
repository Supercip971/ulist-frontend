import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ulist/pages/login_page.dart';
import 'package:ulist/pocket_base.dart';
import '../services.dart';
import '../pocket_base.dart';

import 'package:ulist/utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController(text: 'cyp');
  TextEditingController emailController =
      TextEditingController(text: (kDebugMode) ? "supercyp971@gmail.com" : "");
  TextEditingController passwordController =
      TextEditingController(text: (kDebugMode) ? 'test123123' : "");
  TextEditingController passwordConfirmController =
      TextEditingController(text: (kDebugMode) ? 'test123123' : "");

  var currentError = "";
  @override
  Widget build(BuildContext context) {
    var pbc = getIt<PocketBaseController>();

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

            // USERNAME
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Username",
                      icon: Icon(Icons.account_box)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
              ),

              // EMAIL
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

              // PASSWORD
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

              // PASSWORD CONFIRM
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordConfirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Confirm Password",
                      icon: Icon(Icons.lock)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),

              pad(Text(currentError,
                  style: const TextStyle(color: Colors.red))),

              pad(
                Center(
                  child: Column(children: [
                    pad(ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var res = pbc
                              .register(
                                  usernameController.text,
                                  emailController.text,
                                  passwordController.text,
                                  passwordConfirmController.text)
                              .then((value) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage(
                                        title: "Login", afterRegister: true)));
                          }).catchError((e) {
                            print(e.toString());
                            setState(() =>
                                currentError = deobfuscateError(e.response));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Register failed: ' +
                                      e.response['message'].toString())),
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                      child: const Text('Register'),
                    )),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        pad(TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage(
                                        title: "Login", afterRegister: false)));
                          },
                          child: const Text('Login'),
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
