import 'package:flutter/material.dart';
import 'package:music_app/screens/admin/songs/song_screen.dart';
import './admin_widgets/nav_bottom.dart';
import './admin_widgets/admin_header.dart';
import 'admin.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 3;

  final List<Widget> _pages = [
    const Center(child: Text('Dashboard')),
    // const Center(child: Text('Bài hát')),
    const SongScreen(),
    const Center(child: Text('Nghệ sĩ')),
    // const Center(child: Text('Album')),
    const AdminScreen(),
    const Center(child: Text('Tài khoản')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F2),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            AdminHeader(
              onToggleTheme: () {
                debugPrint('Toggle theme');
              },
              onAvatarTap: () {
                debugPrint('Avatar tapped');
              },
            ),

            /// BODY
            Expanded(
              child: _pages[_currentIndex],
            ),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}