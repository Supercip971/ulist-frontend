import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:get_it/get_it.dart';
import 'package:ulist/list.dart';
import 'package:ulist/user.dart';
import 'services.dart';

import 'user.dart';

const pb_url = ("http://127.0.0.1:8090");

class PocketBaseController {
  PocketBase pb = PocketBase(pb_url);

  var secureStorage = getIt<FlutterSecureStorage>();

  var _loaded = false;

  bool get loaded => _loaded;

  var logged_in = false;

  Future<bool?> logout() async {
    await secureStorage.delete(key: 'auth_token');
    logged_in = false;
    pb.authStore.clear();
    return true;
  }

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
    if (_loaded) {
      return;
    }
    await load_login_tokens();

    _loaded = true;
  }

  User? current_user() {
    if (pb.authStore.isValid) {
      return User.fromJson(pb.authStore.model.toJson());
    }
    return null;
  }

  Future<List<ShoppingListRight>> current_user_lists_right() async {
    var user = current_user();
    if (user == null) {
      return [];
    }

    final result_list =
        await pb.send("/api/v1/get-lists", method: "GET", query: {});

    if (result_list["count"] == 0) {
      return [];
    }

    List<dynamic> data = result_list["lists"];
    //   print(result_list);

    List<ShoppingListRight> lists = [];

    for (var element in data) {
      lists.add(ShoppingListRight.fromJson(element));
    }
    return lists;
  }

  Future<bool> send_list_changes(
      ShoppingList from, ShoppingListUpdate updates) async {
    print(updates.toJson().toString());
    var result_list = pb.send(
      "/api/v1/list-entries",
      method: "POST",
      query: {
        "id": from.uid,
      },
      body: updates.toJson(),
    );

    return true;
  }

  // todo: changes so that we can accummulate changes and send them in one go
  // everything is set up for that, but I'm not familiar with dart enough to do it

  Future<bool> list_entry_add(
      ShoppingList from, ShoppingListEntryPush entry) async {
    ShoppingListUpdate update = ShoppingListUpdate();
    update.pushes = [entry];
    update.id = from.uid;
    send_list_changes(from, update);

    return true;
  }

  Future<bool> list_entry_update(
      ShoppingList from, ShoppingListEntryUpdate entry) async {
    ShoppingListUpdate update = ShoppingListUpdate();
    update.updates = [entry];
    update.pushes = [];
    update.id = from.uid;
    send_list_changes(from, update);

    return true;
  }

  Future<List<ShoppingListEntry>> get_list_entries(ShoppingList from) async {
    var result_list = await pb.send(
      "/api/v1/list-entries",
      method: "GET",
      query: {
        "id": from.uid,
      },
    );

    List<ShoppingListEntry> lists = [];

    print(result_list);
    for (var element in result_list["entries"]) {
      lists.add(ShoppingListEntry.fromJson(element));
    }
    return lists;
  }

  Future<ShoppingList> get_list(String id) async {
    var result_list = await pb.send(
      "/api/v1/list",
      method: "GET",
      query: {
        "id": id,
      },
    );

    return ShoppingList.fromJson(result_list);
  }

  Future<List<ShoppingList>> current_user_lists() async {
    var usable_list = await current_user_lists_right();
    List<ShoppingList> lists = [];
    for (var element in usable_list) {
      lists.add(await get_list(element.shoppingListId));
    }

    return lists;
  }

  // Future<String> get_list_name()
  // Future<List<String>> get_lists_names()

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

  Future<RecordModel?> register(String username, String email, String password,
      String passwordConfirm) async {
    var response = await pb.collection('users').create(
      body: {
        'name': username,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm
      },
    );

    logged_in = false;
    return response;
  }
}

String deobfuscateError(Map res) {
  // print(res.toString());
  var original = res;

  if (!original.containsKey("data")) {
    return "Please retry later, sorry for the inconvenience.";
  }

  // response: {code: 400, message: Failed to create record., data: {email: {code: validation_is_email, message: Must be a valid email address.}}}, originalError: null}
  if (original["data"].containsKey("email")) {
    var email = original["data"]["email"];
    if (email.containsKey("message")) {
      return email["message"];
    }

    return "There is an unknown issue with you're email address.";
  }

  //  response: {code: 400, message: Failed to create record., data: {password: {code: validation_length_out_of_range, message: The length must be between 8 and 72.}}}

  if (original["data"].containsKey("password")) {
    var pass = original["data"]["password"];
    if (pass.containsKey("message")) {
      return pass["message"];
    }

    return "There is an unknown issue with you're password.";
  }

  return "Please retry later, sorry for the inconvenience.";
}
