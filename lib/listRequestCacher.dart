import 'package:ulist/list.dart';
import 'package:ulist/pocket_base.dart';
import 'package:ulist/services.dart';

class ListCacheEntry {
  List<ShoppingListEntry> entries;
  DateTime last_updated;
  ListCacheEntry(this.entries, this.last_updated);

  bool is_outdated() {
    var now = DateTime.now();
    var diff = now.difference(last_updated);
    return diff.inSeconds > 30;
  }
}

class ListRequestCacher {
  var pbc = getIt<PocketBaseController>();

  var _cache = <String, ListCacheEntry>{};

  bool has_entry_cached(ShoppingList entry) {
    return _cache[entry.uid] != null && !_cache[entry.uid]!.is_outdated();
  }

  bool insert_cached_entry(ShoppingList list, ShoppingListEntry updated) {
    var cached = _cache[list.uid];
    if (cached == null) {
      print("Invalid cache entry ${list.uid}");

      return false;
    }

    updated.local = true;
    cached.entries.add(updated);

    return true;
  }

  bool update_cached_entry(ShoppingList list, ShoppingListEntry updated) {
    var cached = _cache[list.uid];
    if (cached == null) {
      print("Invalid cache entry ${list.uid}");

      return false;
    }

    var index =
        cached.entries.indexWhere((element) => element.uid == updated.uid);
    if (index == -1) {
      return false;
    }

    cached.entries[index] = updated;
    return true;
  }

  List<ShoppingListEntry>? get_list_entries_only_cached(ShoppingList list) {
    var cached = _cache[list.uid];
    if (cached != null) {
      return cached.entries;
    }

    return null;
  }

  Future<List<ShoppingListEntry>> get_list_entries_cached(ShoppingList list,
      {bool refresh_cache = false}) async {
    var cached = _cache[list.uid];
    if (cached != null && !cached.is_outdated() && !refresh_cache) {
      return cached.entries;
    }

    var entries = await pbc.get_list_entries(list);
    _cache[list.uid] = ListCacheEntry(entries, DateTime.now());
    return entries;
  }

  Future<bool> list_preload_entries() async {
    var lists = await pbc.current_user_lists();
    for (var list in lists) {
      await get_list_entries_cached(list);
    }
    return true;
  }

  Future<List<ShoppingListEntry>> list_entry_refresh(ShoppingList list) async {
    var entries = await pbc.get_list_entries(list);
    _cache[list.uid] = ListCacheEntry(entries, DateTime.now());
    return _cache[list.uid]!.entries;
  }

  Future<void> list_entry_subscribe(ShoppingList list) async {}

  Future<void> list_entry_unsubscribe(ShoppingList list) async {}
}
