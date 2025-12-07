import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/genre_list_screen.dart';
import 'screens/home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  // Tạm thời comment để test app, uncomment sau khi đã thêm google-services.json
  // try {
  //   await Firebase.initializeApp();
  //   print('Firebase initialized successfully');
  // } catch (e) {
  //   print('Firebase initialization error: $e');
  // }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

