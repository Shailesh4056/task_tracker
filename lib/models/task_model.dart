import 'package:hive_flutter/hive_flutter.dart';  // ✅ changed from hive/hive.dart

part 'task_model.g.dart';

const String statusPending = 'pending';
const String statusCompleted = 'completed';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String status;

  @HiveField(4)
  DateTime lastUpdatedAt;

  @HiveField(5)
  DateTime? lastSyncedAt;

  @HiveField(6)
  bool isDirty;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.status = statusPending,
    required this.lastUpdatedAt,
    this.lastSyncedAt,
    this.isDirty = true,
  });
}