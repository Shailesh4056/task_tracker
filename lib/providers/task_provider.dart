import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/hive_service.dart';

enum SyncStatus { idle, syncing, success, failed }

class TaskProvider extends ChangeNotifier {
  final HiveService _hiveService;
  final _uuid = const Uuid();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  SyncStatus _syncStatus = SyncStatus.idle;
  String? _errorMessage;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  SyncStatus get syncStatus => _syncStatus;
  String? get errorMessage => _errorMessage;
  bool get hasUnsyncedTasks => _tasks.any((t) => t.isDirty);

  TaskProvider(this._hiveService);

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = _hiveService.getAllTasks();
      _tasks.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    } catch (e) {
      _errorMessage = 'Failed to load tasks. Please restart the app.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    String? description,
  }) async {
    try {
      final task = TaskModel(
        id: _uuid.v4(),
        title: title.trim(),
        description: description?.trim(),
        lastUpdatedAt: DateTime.now(),
        isDirty: true,
      );
      await _hiveService.saveTask(task);
      _tasks.insert(0, task);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add task.';
      notifyListeners();
    }
  }

  Future<void> updateTask({
    required String id,
    required String title,
    String? description,
    String? status,
  }) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index == -1) return;

      final task = _tasks[index];
      task.title = title.trim();
      task.description = description?.trim();
      task.status = status ?? task.status;
      task.lastUpdatedAt = DateTime.now();
      task.isDirty = true; // mark dirty on every edit

      await _hiveService.saveTask(task);
      _tasks.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update task.';
      notifyListeners();
    }
  }

  Future<void> toggleStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final newStatus =
    task.status == statusPending ? statusCompleted : statusPending;
    await updateTask(
      id: id,
      title: task.title,
      description: task.description,
      status: newStatus,
    );
  }

  Future<void> deleteTask(String id) async {
    try {
      await _hiveService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete task.';
      notifyListeners();
    }
  }

  Future<void> syncTasks() async {
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      final syncedAt = DateTime.now();
      await _hiveService.updateAllSynced(syncedAt);

      for (final task in _tasks) {
        task.lastSyncedAt = syncedAt;
        task.isDirty = false;
      }

      _syncStatus = SyncStatus.success;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      _syncStatus = SyncStatus.idle;
      notifyListeners();
    } catch (e) {
      _syncStatus = SyncStatus.failed;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      _syncStatus = SyncStatus.idle;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}