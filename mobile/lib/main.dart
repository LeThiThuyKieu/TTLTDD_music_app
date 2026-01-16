// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'screens/genre_list_screen.dart';
// import 'screens/home_screen.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Khởi tạo Firebase
//   // Tạm thời comment để test app, uncomment sau khi đã thêm google-services.json
//   // try {
//   //   await Firebase.initializeApp();
//   //   print('Firebase initialized successfully');
//   // } catch (e) {
//   //   print('Firebase initialization error: $e');
//   // }
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Musea',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//     );
//   }
//
// }
//
import 'package:flutter/material.dart';
import 'package:music_app/screens/onboarding/splash_screen.dart';
import 'package:music_app/utils/theme_provider.dart';
import 'package:provider/provider.dart';

import 'screens/main_screen.dart';
// import 'screens/admin/admin_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'services/audio_player_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Musea',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
              ),
              useMaterial3: true,
            ),

            darkTheme: ThemeData.dark(),

            themeMode: themeProvider.themeMode,

            home: const SplashScreen(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/register': (context) => const RegisterScreen(),
              '/login': (context) => const LoginScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );

  }
}

