import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../../models/artist_model.dart';
import '../../../models/genre_model.dart';
import '../../../services/admin/admin_song_service.dart';
import '../../../services/admin/admin_genre_service.dart';
import '../../../services/admin/admin_artist_service.dart';
import 'widgets/audio_preview_player.dart';

class AdminAddSongScreen extends StatefulWidget {
  const AdminAddSongScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddSongScreen> createState() => _AdminAddSongScreenState();
}

class _AdminAddSongScreenState extends State<AdminAddSongScreen> {
  //service
  final SongService _songService = SongService();
  final GenreService _genreService = GenreService();
  final ArtistService _artistService = ArtistService();
  //control
  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _lyricsCtrl = TextEditingController();
  // state
  bool isSubmitting = false;
  bool isLoadingMeta = true;

  File? musicFile;
  File? coverImage;
  int? duration;

  List<GenreModel> genres = [];
  List<ArtistModel> artists = [];
  GenreModel? selectedGenre;
  ArtistModel? selectedArtist;
  // final genres = ['Pop', 'Rock', 'Ballad', 'EDM', 'Khác'];
  // final artists = ['Sơn Tùng M-TP', 'Hoàng Dũng', 'Mỹ Tâm'];

  @override
  void initState() {
    super.initState();
    _loadMetaData();
  }
// Load artist và genre
  Future<void> _loadMetaData() async {
    try {
      final g = await _genreService.getAllGenres();
      final a = await _artistService.getAllArtists();

      setState(() {
        genres = g;
        artists = a;
        isLoadingMeta = false;
      });
    } catch (e) {
      debugPrint('Load meta error: $e');
      setState(() => isLoadingMeta = false);
    }
  }

// Hàm upload file
  Future<void> _pickMusicFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      // just_audio để đọc duration tự động
      final player = AudioPlayer();
      await player.setFilePath(file.path);
      final d = player.duration;
      await player.dispose();

      setState(() {
        musicFile = file;
        duration = d?.inSeconds ?? 0;
        _durationCtrl.text = duration.toString();
      });
    }
  }

  // Hmaf upload ảnh
  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        coverImage = File(result.files.single.path!);
      });
    }
  }
  //
  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty ||
        musicFile == null ||
        selectedGenre == null ||
        selectedArtist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
      );
      return;
    }
    try {
      setState(() {
        isSubmitting = true;
      });

      await _songService.createSong(
        title: _titleCtrl.text,
        genreId: selectedGenre!.genreId!,
        artistIds: [selectedArtist!.artistId!],
        duration: duration ?? 0,
        lyrics: _lyricsCtrl.text,
        musicFile: musicFile,
        coverImage: coverImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm bài hát thành công')),
      );

      Navigator.pop(context, true); // quay lại danh sách trả kq thành công
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
        elevation: 0,
        backgroundColor: const Color(0xFFF1F6F1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm bài hát',
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
            _infoSection(), //Thông tin bài hát
            const SizedBox(height: 20),
            _lyricsSection(), //Lyrics
            const SizedBox(height: 20),
            _uploadMusicSection(), // upload file mp3
            // player
            if (musicFile != null) ...[
              const SizedBox(height: 12),
              AudioPreviewPlayer(
                localFile: musicFile,
              ),
            ],
            const SizedBox(height: 20),
            _uploadImageSection(), // upload ảnh nền
            const SizedBox(height: 28),
            _actionButtons(), // nút huỷ, theem
          ],
        ),
      ),
    );
  }

  // ================= THÔNG TIN BÀI HÁT =================
  Widget _infoSection() {
    return _card(
      title: 'Thông tin bài hát',
      child: Column(
        children: [
          _input(_titleCtrl, 'Tên bài hát'),
          const SizedBox(height: 14),
          _genreDropdown(),
          const SizedBox(height: 14),
          _artistDropdown(),
          const SizedBox(height: 14),
          _input(_durationCtrl, 'Duration (giây)',
              keyboardType: TextInputType.number,  enabled: false,),
        ],
      ),
    );
  }
  // ================= LYRIC =================
  Widget _lyricsSection() {
    return _card(
      title: 'Chi tiết',
      subtitle: 'Nhập lời bài hát',
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: TextField(
          controller: _lyricsCtrl,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            hintText: 'Nhập lời bài hát...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ================= UPLOAD MUSIC =================
  Widget _uploadMusicSection() {
    return _card(
      title: 'File nhạc',
      subtitle: musicFile != null
          ? 'Đã chọn: ${musicFile!.path.split('/').last}'
          : 'Chấp nhận file .mp3',
      child: _uploadArea(
        icon: Icons.music_note,
        text: musicFile == null
            ? 'Click để upload file nhạc'
            : 'Đổi file nhạc',
        onTap: _pickMusicFile, // upload file
      ),
    );
  }

  // ================= UPLOAD IMAGE =================
  Widget _uploadImageSection() {
    return _card(
      title: 'Upload ảnh cover',
      subtitle: 'JPG, PNG ',
      child: InkWell(
        onTap: _pickCoverImage,
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8DB27C)),
          ),
          child: coverImage == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.image,
                  size: 40, color: Color(0xFF8DB27C)),
              SizedBox(height: 10),
              Text('Click để upload ảnh',
                  style: TextStyle(color: Colors.black54)),
            ],
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              coverImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
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
            child: const Text('Huỷ', style: TextStyle(color: Colors.white),),
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
                : const Text('Thêm mới', style: TextStyle(color: Colors.white),),
          ),
        ),
      ],
    );
  }

  // ================= Widget card dùng chung các viền bên ngoài=================
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
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _input(TextEditingController c, String hint,
      {TextInputType keyboardType = TextInputType.text, bool enabled = true,}) {
    return TextField(
      controller: c,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget _dropdown(String hint, List<String> items, String? value,
  //     ValueChanged<String?> onChanged) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         isExpanded: true,
  //         value: value,
  //         hint: Text(hint),
  //         items: items
  //             .map((e) =>
  //             DropdownMenuItem(value: e, child: Text(e)))
  //             .toList(),
  //         onChanged: onChanged,
  //       ),
  //     ),
  //   );
  // }

  Widget _genreDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GenreModel>(
          isExpanded: true,
          value: selectedGenre,
          hint: const Text('Thể loại'),
          items: genres.map((g) {
            return DropdownMenuItem(
              value: g,
              child: Text(g.name),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedGenre = v),
        ),
      ),
    );
  }

  Widget _artistDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ArtistModel>(
          isExpanded: true,
          value: selectedArtist,
          hint: const Text('Ca sĩ'),
          items: artists.map((a) {
            return DropdownMenuItem(
              value: a,
              child: Text(a.name),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedArtist = v),
        ),
      ),
    );
  }

  Widget _uploadArea({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap, // callback
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8DB27C),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF8DB27C)),
            const SizedBox(height: 10),
            Text(text,
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
