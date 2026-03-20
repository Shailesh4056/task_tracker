import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'services/hive_service.dart';
import 'ui/screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(HiveService()),
      child: MaterialApp(
        title: 'Task Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}