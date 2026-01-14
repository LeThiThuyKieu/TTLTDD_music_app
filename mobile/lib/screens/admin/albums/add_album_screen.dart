import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../models/artist_model.dart';
import '../../../models/song_model.dart';
import '../../../services/admin/admin_album_service.dart';
import '../../../services/admin/admin_artist_service.dart';
import '../../../services/admin/admin_song_service.dart';

class AdminAddAlbumScreen extends StatefulWidget {
  const AdminAddAlbumScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddAlbumScreen> createState() => _AdminAddAlbumScreenState();
}

class _AdminAddAlbumScreenState extends State<AdminAddAlbumScreen> {
  final _nameCtrl = TextEditingController();
  final _albumService = AlbumService();
  final _artistService = ArtistService();
  final _songService = SongService();

  File? coverFile;
  bool isSubmitting = false;

  List<ArtistModel> artists = [];
  ArtistModel? selectedArtist;

  List<SongModel> songs = [];
  List<int> selectedSongIds = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtistsAndSongs();
  }

  Future<void> _loadArtistsAndSongs() async {
    try {
      setState(() => isLoading = true);

      // Lấy danh sách nghệ sĩ
      final fetchedArtists = await _artistService.getAllArtists(limit: 100, offset: 0);

      // Lấy tất cả bài hát
      final fetchedSongs = await _songService.getAllSongs(limit: 200, offset: 0);

      // Lọc những bài chưa có album
      final songsWithoutAlbum = fetchedSongs.where((s) => s.albumId == null).toList(); // Lấy ra bài hát có albumId = null

      setState(() {
        artists = fetchedArtists;
        songs = songsWithoutAlbum; // chỉ những bài chưa có album
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load artists/songs error: $e');
      setState(() => isLoading = false);
    }
  }


  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => coverFile = File(result.files.single.path!));
    }
  }

  void _toggleSongSelection(int songId) {
    setState(() {
      if (selectedSongIds.contains(songId)) {
        selectedSongIds.remove(songId);
      } else {
        selectedSongIds.add(songId);
      }
    });
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || selectedArtist == null || coverFile == null || selectedSongIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      await _albumService.createAlbum(
        title: _nameCtrl.text,
        artistId: selectedArtist!.artistId!,
        songIds: selectedSongIds,
        coverFile: coverFile!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm album thành công')),
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
          'Thêm Album',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3930)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard(),
            const SizedBox(height: 20),
            _coverCard(),
            const SizedBox(height: 28),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return _card(
      title: 'Thông tin Album',
      child: Column(
        children: [
          // Tên album
          _input(_nameCtrl, 'Tên album'),
          const SizedBox(height: 16),
          // Dropdown chọn nghệ sĩ
          DropdownButtonFormField<ArtistModel>(
            value: selectedArtist,
            items: artists
                .map((artist) => DropdownMenuItem(
              value: artist,
              child: Text(artist.name),
            ))
                .toList(),
            onChanged: (artist) => setState(() => selectedArtist = artist),
            decoration: InputDecoration(
              hintText: 'Chọn nghệ sĩ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Multi-select bài hát
          _card(
            title: 'Chọn bài hát cho album',
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: ListView(
                children: songs.map((song) {
                  final selected = selectedSongIds.contains(song.songId);
                  return CheckboxListTile(
                    title: Text(song.title),
                    value: selected,
                    onChanged: (_) => _toggleSongSelection(song.songId!),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverCard() {
    return _card(
      title: 'Cover Album',
      subtitle: 'JPG, PNG',
      child: InkWell(
        onTap: _pickCover,
        child: Container(
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8DB27C)),
          ),
          child: coverFile == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image, size: 40, color: Color(0xFF8DB27C)),
              SizedBox(height: 10),
              Text('Click để upload cover', style: TextStyle(color: Colors.black54)),
            ],
          )
              : Image.file(coverFile!, fit: BoxFit.cover),
        ),
      ),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Thêm Album', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // Shared card widget
  Widget _card({required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
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
