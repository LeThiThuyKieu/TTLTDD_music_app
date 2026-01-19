import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../services/admin/admin_artist_service.dart';

class AdminAddArtistScreen extends StatefulWidget {
  const AdminAddArtistScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddArtistScreen> createState() => _AdminAddArtistScreenState();
}

class _AdminAddArtistScreenState extends State<AdminAddArtistScreen> {
  final ArtistService _artistService = ArtistService();

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  File? avatarImage;
  bool isSubmitting = false;

  // ================= PICK AVATAR =================
  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        avatarImage = File(result.files.single.path!);
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || avatarImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      await _artistService.createArtist(
        name: _nameCtrl.text,
        avatarFile: avatarImage!,
        description: _bioCtrl.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm nghệ sĩ thành công')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F6F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm nghệ sĩ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3930),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _avatarCard(),
            const SizedBox(height: 20),
            _infoCard(),
            const SizedBox(height: 20),
            _bioCard(),
            const SizedBox(height: 28),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  // ================= CARD 1: AVATAR =================
  Widget _avatarCard() {
    return _card(
      title: 'Avatar nghệ sĩ',
      subtitle: 'JPG, PNG',
      child: InkWell(
        onTap: _pickAvatar,
        child: Container(
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8DB27C)),
          ),
          child: avatarImage == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person,
                  size: 40, color: Color(0xFF8DB27C)),
              SizedBox(height: 10),
              Text('Click để upload avatar',
                  style: TextStyle(color: Colors.black54)),
            ],
          )
              : CircleAvatar(
            radius: 55,
            backgroundImage: FileImage(avatarImage!),
          ),
        ),
      ),
    );
  }

  // ================= CARD 2: INFO =================
  Widget _infoCard() {
    return _card(
      title: 'Thông tin nghệ sĩ',
      child: Column(
        children: [
          _input(_nameCtrl, 'Tên nghệ sĩ'),
        ],
      ),
    );
  }

  // ================= CARD 3: BIO =================
  Widget _bioCard() {
    return _card(
      title: 'Mô tả',
      subtitle: 'Giới thiệu về nghệ sĩ',
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: TextField(
          controller: _bioCtrl,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            hintText: 'Nhập mô tả nghệ sĩ...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Huỷ', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8DB27C),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text('Thêm mới',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ================= SHARED WIDGETS =================
  Widget _card({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
