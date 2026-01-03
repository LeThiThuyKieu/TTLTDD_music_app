import 'package:flutter/material.dart';
import 'package:music_app/services/profile_service.dart';
import '../utils/toast.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;

  const EditProfileScreen({
    super.key,
    required this.currentName,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _profileService.updateProfile(
        name: _nameController.text.trim(),
      );

      if (!mounted) return;

      showToast(
        message: 'Cập nhật thông tin thành công',
        isSuccess: true,
      );

      Navigator.of(context).pop(true); // quay về profile
    } catch (e) {
      if (!mounted) return;

      showToast(
        message: e.toString().replaceAll('Exception: ', ''),
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
