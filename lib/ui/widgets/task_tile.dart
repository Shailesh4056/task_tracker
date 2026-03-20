import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == statusCompleted;
    final formattedDate =
    DateFormat('dd MMM, hh:mm a').format(task.lastUpdatedAt);

    return Card(
      margin:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
         EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: onToggleStatus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.transparent,
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  task.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:  TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
              ),
            4.verticalSpace,
            Row(
              children: [
                Icon(Icons.access_time, size: 12.sp, color: Colors.grey.shade500),
               4.horizontalSpace,
                Text(
                  formattedDate,
                  style:
                  TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                ),
             10.horizontalSpace,
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: task.isDirty
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        task.isDirty ? Icons.sync_problem : Icons.cloud_done,
                        size: 11.sp,
                        color: task.isDirty ? Colors.orange : Colors.green,
                      ),
                     3.horizontalSpace,
                      Text(
                        task.isDirty ? 'Unsynced' : 'Synced',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color:
                          task.isDirty ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon:  Icon(Icons.edit_outlined, size: 20.sp),
              onPressed: onTap,
              color: Colors.blueGrey,
            ),
            IconButton(
              icon:  Icon(Icons.delete_outline, size: 20.sp),
              onPressed: onDelete,
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}