import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../services/profile_service.dart';
import '../utils/theme_provider.dart';
import '../services/auth_service.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import '../utils/toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  String? name;
  String? email;
  String? avatarUrl;

  File? _localAvatar;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userName = await _authService.getUserName();
    final userEmail = await _authService.getUserEmail();
    final userAvatarUrl = await _authService.getUserAvatar();

    if (!mounted) return;

    setState(() {
      name = userName;
      email = userEmail;
      avatarUrl = userAvatarUrl;
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
              navigator.pop(); // đóng dialog

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

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;
    final file = File(image.path);
    setState(() {
      _localAvatar = file;
    });

    try {
      final avatarPath = await _profileService.uploadAvatar(file);
      // ví dụ avatarPath = "/uploads/avatar/avatar-xxx.png"

      if (!mounted) return;

      // Ghép baseUrl (do backend trả về tuong đối như trên
      final fullAvatarUrl = '${ApiConfig.baseUrl}$avatarPath';

      // Lưu vào local
      await _authService.saveUserAvatar(fullAvatarUrl);

      // Update UI
      setState(() {
        avatarUrl = fullAvatarUrl;
        _localAvatar = null; // chuyển sang ảnh từ server
      });

      showToast(
        message: 'Cập nhật avatar thành công',
      );
    } catch (e) {
      setState(() {
        _localAvatar = null; // rollback nếu lỗi
      });

      showToast(
        message:
            'Cập nhật avatar thất bại: ${e.toString().replaceAll('Exception: ', '')}',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (_localAvatar != null) {
      avatarImage = FileImage(_localAvatar!);
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(avatarUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /// AVATAR
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(Icons.person,
                            size: 52, color: Colors.white)
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF1ED760),
                      child: Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),

              // NAME
              Text(
                name ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // EMAIL
              Text(
                email ?? '',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              //Edit info (name, mail ko đổi)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Chỉnh sửa thông tin'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        currentName: name ?? '',
                      ),
                    ),
                  );

                  // Nếu edit profile thành công → reload lại user
                  if (result == true) {
                    await _loadUser();
                  }
                },
              ),

              const SizedBox(height: 24),

              // CHANGE PASSWORD
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: const Text('Đổi mật khẩu'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final navigator = Navigator.of(context);

                  if (!mounted) return;

                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Light/Dark mode
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                trailing: Switch(
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().toggleTheme(value);
                  },
                ),
              ),

              const Spacer(),

              // LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ED760),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
