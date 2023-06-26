import 'dart:convert';

class ShoppingList {
  String name = "";
  String uid = "";
  ShoppingList({this.name = "", this.uid = ""});

  factory ShoppingList.fromJson(Map<String, dynamic> responseData) {
    return ShoppingList()
      ..name = responseData['name']
      ..uid = responseData['id'];
  }
}

class ShoppingListEntry {
  String name = "";
  String uid = "";
  String shoppingListId = "";
  String addedBy = "";
  bool checked = false;

  // local means that the entry has the current state modified  here and not from the server
  // So that means that we should upload it to the server when we get the chance
  bool local = false; // default local to false

  ShoppingListEntry(
      {this.name = "",
      this.uid = "",
      this.shoppingListId = "",
      this.checked = false,
      this.local = false});

  factory ShoppingListEntry.fromJson(Map<String, dynamic> responseData) {
    return ShoppingListEntry()
      ..name = responseData['name']
      ..uid = responseData['id']
      ..shoppingListId = responseData['list']
      ..addedBy = responseData['addedBy']
      ..checked = responseData['checked'];
  }
}

class ShoppingListRight {
  String uid = "";
  String shoppingListId = "";
  String userId = "";
  bool owner = false;

  ShoppingListRight(
      {this.uid = "",
      this.shoppingListId = "",
      this.userId = "",
      this.owner = false});

  factory ShoppingListRight.fromJson(Map<String, dynamic> responseData) {
    return ShoppingListRight()
      ..userId = responseData['userId']
      ..shoppingListId = responseData['listId']
      ..owner = responseData['owner']
      ..uid = responseData['id'];
  }

  Map<String, dynamic> toJson() => {
		'userId': userId,
		'listId': shoppingListId,
		'owner': owner,
		'id': uid,
	  };
}

class ShoppingListEntryUpdate {
  String id = "";
  String name = "";
  bool checked = false;

  ShoppingListEntryUpdate({this.id = "", this.name = "", this.checked = false});

  factory ShoppingListEntryUpdate.fromJson(Map<String, dynamic> responseData) {
    return ShoppingListEntryUpdate()
      ..id = responseData['id']
      ..name = responseData['name']
      ..checked = responseData['checked'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'checked': checked,
      };

  factory ShoppingListEntryUpdate.fromEntry(ShoppingListEntry entry) {
    return ShoppingListEntryUpdate()
      ..id = entry.uid
      ..name = entry.name
      ..checked = entry.checked;
  }
}

class ShoppingListEntryPush {
  String name = "";
  bool checked = false;

  ShoppingListEntryPush({this.name = "", this.checked = false});

  factory ShoppingListEntryPush.fromJson(Map<String, dynamic> responseData) {
    return ShoppingListEntryPush()
      ..name = responseData['name']
      ..checked = responseData['checked'];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'checked': checked,
      };

  factory ShoppingListEntryPush.fromEntry(ShoppingListEntry entry) {
    return ShoppingListEntryPush()
      ..name = entry.name
      ..checked = entry.checked;
  }
}

class ShoppingListUpdate {
  String id = "";

  List<ShoppingListEntryUpdate> updates = [];
  List<ShoppingListEntryPush> pushes = [];

  ShoppingListUpdate(
      {this.id = "", this.updates = const [], this.pushes = const []});

  Map<String, dynamic> toJson() => {
        'id': id,
        'updates': updates.map((e) => e.toJson()).toList(),
        'pushes': pushes.map((e) => e.toJson()).toList(),
      };
}

/*
type ListShare struct {
	models.BaseModel

	List           string         `db:"list" json:"list"`
	SharedBy       string         `db:"sharedBy" json:"sharedBy"`
	ExpirationDate types.DateTime `db:"expirationDate" json:"expirationDate"`
	Identifier     string         `db:"identificator" json:"identificator"`
}


*/
class ShoppingListShare {
  String listId = ""; // list
  String sharedBy = ""; // sharedBy
  String expirationDate = ""; // expirationDate
  String identificator = ""; // identifier

  ShoppingListShare({
    this.listId = "",
    this.sharedBy = "",
    this.expirationDate = "",
    this.identificator = "",
  });

  factory ShoppingListShare.fromJson(Map<String, dynamic> responseData) {
    return ShoppingListShare()
      ..listId = responseData['list']
      ..sharedBy = responseData['sharedBy']
      ..expirationDate = responseData['expirationDate']
      ..identificator = responseData['identificator'];
  }

  Map<String, dynamic> toJson() => {
        'list': listId,
        'sharedBy': sharedBy,
        'expirationDate': expirationDate,
        'identificator': identificator,
      };
}



class ShoppingListPropsShare {
  String sharedBy = ""; // sharedBy
  String expirationDate = ""; // expirationDate
  String identificator = ""; // identifier

  ShoppingListPropsShare({
    this.sharedBy = "",
    this.expirationDate = "",
    this.identificator = "",
  });

  factory ShoppingListPropsShare.fromJson(Map<String, dynamic> responseData) {
    return ShoppingListPropsShare()
      ..sharedBy = responseData['sharedBy']
      ..expirationDate = responseData['expirationDate']
      ..identificator = responseData['identificator'];
  }
}

class ShoppingListPropsUser {
  String name = ""; 
  String id = ""; 
  bool owner = false;  

  ShoppingListPropsUser({
    this.name = "",
    this.id = "",
    this.owner = false, 
  });

  factory ShoppingListPropsUser.fromJson(Map<String, dynamic> responseData) {
    return ShoppingListPropsUser()
      ..name = responseData['name']
      ..id = responseData['id']
      ..owner = responseData['owner'];
  }

}

class ShoppingListInformation {
	List<ShoppingListPropsShare> shares = [];
	List<ShoppingListPropsUser> users = [];
	
	ShoppingListInformation({this.shares = const [], this.users = const []});

	factory ShoppingListInformation.fromJson(Map<String, dynamic> responseData) {
		print(responseData);
		return ShoppingListInformation()
			..users = (responseData['users'] as List).map((e) => ShoppingListPropsUser.fromJson(e)).toList()
			..shares = (responseData['shares'] as List).map((e) => ShoppingListPropsShare.fromJson(e)).toList();
	}
}

