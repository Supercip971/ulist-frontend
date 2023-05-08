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

  ShoppingListEntry(
      {this.name = "",
      this.uid = "",
      this.shoppingListId = "",
      this.checked = false});

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
