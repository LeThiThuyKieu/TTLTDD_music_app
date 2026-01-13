import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../models/artist_model.dart';
import '../../../services/admin/admin_artist_service.dart';

class AdminUpdateArtistScreen extends StatefulWidget {
  final int artistId;

  const AdminUpdateArtistScreen({
    Key? key,
    required this.artistId,
  }) : super(key: key);

  @override
  State<AdminUpdateArtistScreen> createState() =>
      _AdminUpdateArtistScreenState();
}

class _AdminUpdateArtistScreenState extends State<AdminUpdateArtistScreen> {
  final ArtistService _artistService = ArtistService();

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  File? avatarFile;
  String? avatarUrl;
  bool isActive = true;

  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadArtistDetail();
  }

  // ================= LOAD DETAIL =================
  Future<void> _loadArtistDetail() async {
    try {
      final ArtistModel artist =
      await _artistService.getArtistDetail(widget.artistId);

      setState(() {
        _nameCtrl.text = artist.name;
        _bioCtrl.text = artist.description ?? '';
        avatarUrl = artist.avatarUrl;
        isActive = artist.isActive == 1;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load artist detail error: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= PICK AVATAR =================
  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        avatarFile = File(result.files.single.path!);
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên nghệ sĩ không được để trống')),
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      await _artistService.updateArtist(
        artistId: widget.artistId,
        name: _nameCtrl.text,
        description: _bioCtrl.text,
        isActive: isActive,
        avatarFile: avatarFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật nghệ sĩ thành công')),
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
          'Cập nhật nghệ sĩ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3930),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _avatarCard(),
            const SizedBox(height: 20),
            _infoCard(),
            const SizedBox(height: 20),
            _bioCard(),
            const SizedBox(height: 20),
            _statusSwitch(),
            const SizedBox(height: 28),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _avatarCard() {
    return _card(
      title: 'Avatar nghệ sĩ',
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
          child: avatarFile != null
              ? CircleAvatar(
            radius: 55,
            backgroundImage: FileImage(avatarFile!),
          )
              : avatarUrl != null
              ? CircleAvatar(
            radius: 55,
            backgroundImage: NetworkImage(avatarUrl!),
          )
              : const Icon(Icons.person, size: 40),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return _card(
      title: 'Thông tin nghệ sĩ',
      child: _input(_nameCtrl, 'Tên nghệ sĩ'),
    );
  }

  Widget _bioCard() {
    return _card(
      title: 'Mô tả',
      child: TextField(
        controller: _bioCtrl,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'Giới thiệu nghệ sĩ...',
          border: OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _statusSwitch() {
    return SwitchListTile(
      title: const Text('Trạng thái hoạt động'),
      value: isActive,
      onChanged: (v) => setState(() => isActive = v),
    );
  }

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
            child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
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
                : const Text('Cập nhật',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _card({
    required String title,
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
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
