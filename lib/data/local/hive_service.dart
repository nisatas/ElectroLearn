import 'package:hive_flutter/hive_flutter.dart';

abstract class HiveService {
  static const String progressBoxName = 'progress';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(progressBoxName);
  }

  static Box<dynamic> get progressBox => Hive.box<dynamic>(progressBoxName);
}
