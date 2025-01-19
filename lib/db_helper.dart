import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static final Box<String> _box = Hive.box<String>('keywords');

  // Get all keywords
  List<String> getKeywords() {
    return _box.values.toList();
  }

  // Add a keyword
  Future<void> addKeyword(String keyword) async {
    await _box.add(keyword);
  }

  // Delete a keyword by index
  Future<void> deleteKeyword(int index) async {
    await _box.deleteAt(index);
  }
}