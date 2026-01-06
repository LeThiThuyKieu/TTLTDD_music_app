import 'package:flutter/material.dart';
import './admin_widgets/nav_bottom.dart';
import './admin_widgets/admin_header.dart';
import 'admin.dart';
import 'package:music_app/screens/admin/songs/song_screen.dart';
import 'package:music_app/screens/admin/artists/artist_screen.dart';
import 'package:music_app/screens/admin/albums/album_screen.dart';
import 'package:music_app/screens/admin/users/user_screen.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<AdminScreen> {
  int _currentIndex = 3;

  final List<Widget> _pages = [
    // const Center(child: Text('Dashboard')),
    const AdminScreen(),
    // const Center(child: Text('Bài hát')),
    const AdminSongScreen(),
    // const Center(child: Text('Nghệ sĩ')),
    const AdminArtistScreen(),
    // const Center(child: Text('Album')),
    const AdminAlbumScreen(),
    // const Center(child: Text('Tài khoản')),
    const AdminUserScreen(),
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