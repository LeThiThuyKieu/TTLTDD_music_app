import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import './admin_widgets/nav_bottom.dart';
// import './admin_widgets/admin_header.dart';
// import 'admin.dart';
import 'package:music_app/screens/admin/songs/song_screen.dart';
import 'package:music_app/screens/admin/artists/artist_screen.dart';
import 'package:music_app/screens/admin/albums/album_screen.dart';
import 'package:music_app/screens/admin/users/user_screen.dart';

import 'dashboard/dashboard_screen.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  String? userName;
  String? avatarUrl;


  final List<Widget> _pages = [
    // const Center(child: Text('Dashboard')),
    MusicDashboardPage(),
    // const Center(child: Text('Bài hát')),
    const AdminSongScreen(),
    // const Center(child: Text('Nghệ sĩ')),
    const AdminArtistScreen(),
    // const Center(child: Text('Album')),
    const AdminAlbumScreen(),
    // const Center(child: Text('Tài khoản')),
    const AdminUserScreen(),
  ];
  // Load user infor
  Future<void> _loadUserInfo() async {
    final name = await _authService.getUserName();
    final avatar = await _authService.getUserAvatar();

    setState(() {
      userName = name;
      avatarUrl = avatar;
    });
  }
// logout
  Future<void> _handleLogout() async {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              navigator.pop();
              await _authService.logout();

              if (!mounted) return;

              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  // header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
            (avatarUrl != null && avatarUrl!.startsWith('http'))
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || !avatarUrl!.startsWith('http'))
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Admin 👋 ${userName ?? ''}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F2),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            // AdminHeader(
            //   onToggleTheme: () {
            //     debugPrint('Toggle theme');
            //   },
            //   onAvatarTap: () {
            //     debugPrint('Avatar tapped');
            //   },
            // ),
            _buildHeader(),
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