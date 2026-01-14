import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../models/artist_model.dart';
import '../../../models/song_model.dart';
import '../../../models/album_model.dart';
import '../../../services/admin/admin_album_service.dart';
import '../../../services/admin/admin_artist_service.dart';
import '../../../services/admin/admin_song_service.dart';

class AdminUpdateAlbumScreen extends StatefulWidget {
  final int albumId;

  const AdminUpdateAlbumScreen({Key? key, required this.albumId}) : super(key: key);

  @override
  State<AdminUpdateAlbumScreen> createState() => _AdminUpdateAlbumScreenState();
}

class _AdminUpdateAlbumScreenState extends State<AdminUpdateAlbumScreen> {
  final _nameCtrl = TextEditingController();
  final _albumService = AlbumService();
  final _artistService = ArtistService();
  final _songService = SongService();

  File? coverFile;
  String? coverUrl;
  bool isSubmitting = false;
  bool isActive = true;

  List<ArtistModel> artists = [];
  ArtistModel? selectedArtist;

  List<SongModel> songs = [];
  List<int> selectedSongIds = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbumDetail();
  }

  Future<void> _loadAlbumDetail() async {
    try {
      setState(() => isLoading = true);

      // Lấy danh sách nghệ sĩ
      final fetchedArtists = await _artistService.getAllArtists(limit: 100, offset: 0);

      // Lấy tất cả bài hát
      final allSongs = await _songService.getAllSongs(limit: 200, offset: 0);

      // Lấy chi tiết album
      final album = await _albumService.getAlbumDetail(widget.albumId);

      // Lọc bài chưa có album
      final songsWithoutAlbum = allSongs.where((s) => s.albumId == null).toList();

      // Lấy danh sách id bài hát đã thuộc album đang edit
      final albumSongIds = album.songs?.map((s) => s.songId!).toList() ?? [];

      // Kết hợp danh sách bài hát (lọc trùng + đúng type)
      final Map<int, SongModel> songMap = {};

// Bài hát đã thuộc album
      for (final s in album.songs ?? <SongModel>[]) {
        if (s.songId != null) {
          songMap[s.songId!] = s;
        }
      }

// Bài hát chưa có album
      for (final s in songsWithoutAlbum) {
        if (s.songId != null) {
          songMap[s.songId!] = s;
        }
      }

      final List<SongModel> combinedSongs = songMap.values.toList();

      setState(() {
        artists = fetchedArtists;
        songs = combinedSongs;

        _nameCtrl.text = album.title;

        // Chọn sẵn nghệ sĩ
        if (artists.isNotEmpty) {
          selectedArtist = artists.firstWhere(
                (a) => a.artistId == album.artistId,
            orElse: () => artists.first, // luôn có giá trị ArtistModel
          );
        } else {
          selectedArtist = null; // list rỗng, không có gì để chọn
        }

        // Tick sẵn các bài đã thuộc album
        selectedSongIds = albumSongIds;

        // Cover và trạng thái
        coverUrl = album.coverUrl;
        isActive = album.isActive == 1;

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load album detail error: $e');
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
    if (_nameCtrl.text.isEmpty || selectedArtist == null || selectedSongIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      await _albumService.updateAlbum(
        albumId: widget.albumId,
        title: _nameCtrl.text,
        artistId: selectedArtist!.artistId!,
        songIds: selectedSongIds,
        coverFile: coverFile,
        isActive: isActive ? 1: 0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật album thành công')),
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
          'Cập nhật Album',
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
            const SizedBox(height: 20),
            _statusSwitch(),
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
          _input(_nameCtrl, 'Tên album'),
          const SizedBox(height: 16),
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
          _card(
            title: 'Chọn bài hát cho album',
            child: Container(
              height: 300,
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
                    value: selectedSongIds.contains(song.songId),
                      onChanged: (bool? checked) {
                        if (song.songId != null) {
                          _toggleSongSelection(song.songId!);
                        }
                      },
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
          child: coverFile != null
              ? Image.file(coverFile!, fit: BoxFit.cover)
              : (coverUrl != null
              ? Image.network(coverUrl!, fit: BoxFit.cover)
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image, size: 40, color: Color(0xFF8DB27C)),
              SizedBox(height: 10),
              Text('Click để upload cover', style: TextStyle(color: Colors.black54)),
            ],
          )),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Cập nhật Album', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

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
