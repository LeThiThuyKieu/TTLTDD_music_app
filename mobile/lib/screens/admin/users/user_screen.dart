import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../admin_widgets/input_box.dart';
import '../admin_widgets/status_filter.dart';
import '../../../services/admin/admin_user_service.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<AdminUserScreen> {
  List<UserModel> allUsers = [];
  String selectedStatus = 'Tất cả';
  String searchText = '';
  bool isLoading = false;
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  Future<void> _loadUsers() async {
    try {
      setState(() => isLoading = true);

      final users = await _userService.getAllUsers(); //JSON được fetch ở đây

      setState(() {
        allUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Load users error: $e');
    }
  }

  // void _loadMockData() {
  //   allUsers = [
  //     UserModel(
  //       userId: 1,
  //       name: 'Nhng',
  //       email: 'nhngdangtest@gmail.com',
  //       role: 'admin',
  //       avatarUrl: 'https://i.ytimg.com/vi/ryC6nsOk5l8/maxresdefault.jpg',
  //       isActive: 1,
  //     ),
  //     UserModel(
  //       userId: 2,
  //       name: 'Test',
  //       email: 'nhanvientest@gmail.com',
  //       role: 'user',
  //       avatarUrl:
  //       'https://i.ytimg.com/vi/ryC6nsOk5l8/maxresdefault.jpg',
  //       isActive: 1,
  //     ),
  //   ];
  // }

  // KHOÁ TÀI KHOẢN
  Future<void> _toggleUserStatus(UserModel user) async {
    final newStatus = user.isActive == 1 ? 0 : 1;

    try {
      //clear snackbar cũ
      ScaffoldMessenger.of(context).clearSnackBars();
      // loading nhẹ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 0 ? 'Đang khoá tài khoản...' : 'Đang mở khoá tài khoản...',
          ),
        ),
      );

      //  Call API
      await _userService.updateUserStatus(user.userId!, newStatus);

      //  Update local sau khi BE OK
      setState(() {
        final index = allUsers.indexWhere((u) => u.userId == user.userId);
        if (index != -1) {
        allUsers[index] = user.copyWith(isActive: newStatus);
        }
      });

      //  Success
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 0 ? 'Khoá tài khoản thành công' : 'Mở khoá tài khoản thành công',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thao tác thất bại: $e')),
      );
    }
  }

  //  search +filter
  List<UserModel> get filteredUsers {
    return allUsers.where((user) {
      final matchSearch = user.name
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchStatus =
          selectedStatus == 'Tất cả' ||
              (selectedStatus == 'Active' && user.isActive == 1) ||
              (selectedStatus == 'Unactive' && user.isActive == 0);

      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PAGE NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tài khoản người dùng',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3930)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6F1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // TIÊU ĐỀ
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_box_outlined, size: 30),
                    SizedBox(width: 15),
                    Text(
                      'Danh sách tài khoản',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// SEARCH
                InputBox(
                  icon: Icons.search,
                  hint: 'Tìm kiếm người dùng...',
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                /// FILTER
                StatusFilter(
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                /// LIST
                ...filteredUsers.map(
                      (user) => UserItem(
                      user: user,
                      onToggleActive: () => _toggleUserStatus(user),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= USER ITEM =================
class UserItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onToggleActive;

  const UserItem({
    required this.user,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user.isActive == 1;
    final isAdmin = user.role == 'admin';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              user.avatarUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade300,
                child: const Icon(Icons.people),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
              ],
            ),
          ),
          //TEXT STATUS
          Text(
            isAdmin ? 'Admin' : 'User',
            style: TextStyle(
              fontSize: 12,
              color: isAdmin ? Colors.blue : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          // ICON khoá
          IconButton(
            icon: Icon(
              isActive ? Icons.lock_open_outlined : Icons.lock_outline,
              color: isAdmin ? Colors.grey : const Color(0xFF8DB27C),
            ),
            onPressed: isAdmin ? null : () => _showLockDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLockDialog(BuildContext context) {
    final isActive = user.isActive == 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(isActive ? 'Khoá tài khoản' : 'Mở khoá tài khoản'),
        content: Text(
          isActive
              ? 'Bạn có chắc muốn khoá tài khoản "${user.name}" không?'
              : 'Bạn có muốn mở khoá tài khoản "${user.name}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.green,
            ),
            onPressed: () {
              Navigator.pop(context);
              onToggleActive(); // đổi trạng thái
            },
            child: Text(isActive ? 'Khoá' : 'Mở khoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}
