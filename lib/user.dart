import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase("http://127.0.0.1:8090");

class User {
  final String userId;
  final String name;
  final String email;
  final String type;
  final String token;
  final String renewalToken;
  final int premiumLevel;

  const User(
      {this.userId = "-1",
      this.name = "",
      this.email = "",
      this.type = "",
      this.token = "",
      this.renewalToken = "",
      this.premiumLevel= 0});

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

