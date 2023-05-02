import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase("http://127.0.0.1:8090");

class User {
  String userId;
  String name;
  String email;
  String type;
  String token;
  String renewalToken;

  User(
      {this.userId = "-1",
      this.name = "",
      this.email = "",
      this.type = "",
      this.token = "",
      this.renewalToken = ""});

  bool isNull() {
    return (userId) == "-1";
  }

  bool isLoggedIn() {
    return true;
  }

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        userId: responseData['id'],
        name: responseData['name'],
        email: responseData['email']
        //   type: responseData['type'],
        //   token: responseData['access_token'],
        //   renewalToken: responseData['renewal_token']);
        );
  }
}
