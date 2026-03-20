import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class HiveService {
  static const String _boxName = 'tasks';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskModelAdapter());
    await Hive.openBox<TaskModel>(_boxName);
  }

  Box<TaskModel> get _box => Hive.box<TaskModel>(_boxName);

  List<TaskModel> getAllTasks() {
    try {
      return _box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTask(TaskModel task) async {
    try {
      await _box.put(task.id, task);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAllSynced(DateTime syncedAt) async {
    try {
      final tasks = _box.values.toList();
      for (final task in tasks) {
        task.lastSyncedAt = syncedAt;
        task.isDirty = false;
        await task.save();
      }
    } catch (e) {
      rethrow;
    }
  }
}