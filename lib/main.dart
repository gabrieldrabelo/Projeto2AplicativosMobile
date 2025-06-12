import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'database/database_helper.dart';
import 'database/migration_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await DatabaseHelper.instance.database;
  
  // Execute data migration after database upgrade
  await MigrationHelper().updateDataAfterMigration();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Force App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}