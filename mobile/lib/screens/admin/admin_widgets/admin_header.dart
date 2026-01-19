import 'package:flutter/material.dart';
class AdminHeader extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final VoidCallback? onAvatarTap;

  const AdminHeader({
    Key? key,
    this.onToggleTheme,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          /// LOGO
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Musea',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          const Spacer(),

          /// LIGHT MODE ICON
          IconButton(
            onPressed: onToggleTheme,
            icon: const Icon(
              Icons.light_mode_outlined,
              color: Colors.black87,
            ),
          ),

          const SizedBox(width: 7),

          /// ===== AVATAR =====
          InkWell(
            onTap: onAvatarTap,
            borderRadius: BorderRadius.circular(30),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=3',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
