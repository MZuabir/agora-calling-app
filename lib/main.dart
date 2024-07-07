import 'dart:async';
import 'package:calling_app/views/app/home/home_screen.dart';
import 'package:calling_app/views/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              color: Colors.cyan,
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold))),
      home:
         
          (FirebaseAuth.instance.currentUser?.email?.isEmpty ?? true)
              ? const LoginScreen()
              : const HomeScreen(),
    );
  }
}

Future<void> requestPermissions() async {
  
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
  ].request();

  if (statuses[Permission.camera] == PermissionStatus.denied ||
      statuses[Permission.microphone] == PermissionStatus.denied) {
    await openAppSettings();
  }
}

