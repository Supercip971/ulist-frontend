import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:get_it/get_it.dart';
import 'package:ulist/user.dart';
import 'services.dart';

import 'user.dart';

const pb_url = ("http://127.0.0.1:8090");

class PocketBaseController {
  PocketBase pb = PocketBase(pb_url);

  var secureStorage = getIt<FlutterSecureStorage>();

  var logged_in = false;
  Future<String?> load_login_tokens() async {
    try {
      var value = await secureStorage.read(key: 'auth_token');
      if (value == null) {
        return null;
      }

      // we store the raw response from the server
      var tok = jsonDecode(value);
      var token = tok['token'] as String?;

      if (token == null) {
        return null;
      }

      if (tok['model'] == null) {
        return null;
      }
      var model = RecordModel.fromJson(tok['model']);

      pb.authStore.save(token, model);

      await pb.collection("users").authRefresh();
      logged_in = pb.authStore.isValid;
      return token;
    } catch (e) {
      return null;
    }
  }

  Future init() async {
    await load_login_tokens();
  }

  User? current_user() {
    if (pb.authStore.isValid) {
      return User.fromJson(pb.authStore.model.toJson());
    }
    return null;
  }

  Future<RecordModel?> login(String email, String password) async {
    var response =
        await pb.collection('users').authWithPassword(email, password);

    if (pb.authStore.isValid) {
      await secureStorage.write(
          key: 'auth_token',
          value: jsonEncode({
            'token': pb.authStore.token,
            'model': pb.authStore.model.toJson()
          }));
      logged_in = true;
      return response.record;
    }

    logged_in = false;
    return null;
  }
}
