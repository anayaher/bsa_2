import 'package:BSA/Features/Auth/Screens/login_screen.dart';
import 'package:BSA/Features/Insurance/data/insurance_db.dart';
import 'package:BSA/Features/Vehicles/db/vehicle_db.dart';
import 'package:BSA/core/Controller/expiry_controller.dart';
import 'package:BSA/core/services/local_data_storage.dart';
import 'package:BSA/dash_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final saved = await LocalStorageService.getPassword();

  // If no password exists, set a default one
  if (saved == null) {
    await LocalStorageService.savePassword("5344");
  }
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BSA Assistant',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
