import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../../models/song_model.dart';
import '../../../models/artist_model.dart';
import '../../../models/genre_model.dart';
import '../../../models/album_model.dart';

import '../../../services/admin/admin_song_service.dart';
import '../../../services/admin/admin_genre_service.dart';
import '../../../services/admin/admin_artist_service.dart';
import '../../../services/admin/admin_album_service.dart';

import 'widgets/audio_preview_player.dart';

class AdminUpdateSongScreen extends StatefulWidget {
  final int songId;

  const AdminUpdateSongScreen({Key? key, required this.songId,})
      : super(key: key);

  @override
  State<AdminUpdateSongScreen> createState() => _AdminUpdateSongScreenState();
}

class _AdminUpdateSongScreenState extends State<AdminUpdateSongScreen> {
  // SERVICES
  final SongService _songService = SongService();
  final GenreService _genreService = GenreService();
  final ArtistService _artistService = ArtistService();
  final AlbumService _albumService = AlbumService();

  // CONTROLLERS
  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _lyricsCtrl = TextEditingController();

  // STATE
  bool isSubmitting = false;
  bool isLoading = true;
  bool isActive = true;

  File? musicFile;
  File? coverImage;

  int duration = 0;

  List<GenreModel> genres = [];
  List<ArtistModel> artists = [];
  List<AlbumModel> albums = [];

  GenreModel? selectedGenre;
  ArtistModel? selectedArtist;
  AlbumModel? selectedAlbum;

  String? oldMusicUrl;
  String? oldCoverUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ================= LOAD DATA =================
  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _songService.getSongDetail(widget.songId),
        _genreService.getAllGenres(),
        _artistService.getAllArtists(),
        _albumService.getAllAlbums(),
      ]);

      final SongModel song = results[0] as SongModel;
      genres = results[1] as List<GenreModel>;
      artists = results[2] as List<ArtistModel>;
      albums = results[3] as List<AlbumModel>;

      _titleCtrl.text = song.title;
      _lyricsCtrl.text = song.lyrics ?? '';
      duration = song.duration ?? 0;
      _durationCtrl.text = duration.toString();
      isActive = song.isActive == 1;

      oldMusicUrl = song.fileUrl;
      oldCoverUrl = song.coverUrl;

      selectedGenre = genres.firstWhere(
            (g) => g.genreId == song.genreId,
        orElse: () => genres.first,
      );

      if (song.artists != null && song.artists!.isNotEmpty) {
        final artistId = song.artists!.first.artistId;
        selectedArtist = artists.firstWhere(
              (a) => a.artistId == artistId,
          orElse: () => artists.first,
        );
      }

      if (song.albumId != null) {
        selectedAlbum = albums.firstWhere(
              (a) => a.albumId == song.albumId,
          orElse: () => albums.first,
        );
      }

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Load update song error: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= PICK MUSIC =================
  Future<void> _pickMusicFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result?.files.single.path != null) {
      final file = File(result!.files.single.path!);
      final player = AudioPlayer();
      await player.setFilePath(file.path);
      final d = player.duration;
      await player.dispose();

      setState(() {
        musicFile = file;
        oldMusicUrl = null;
        duration = d?.inSeconds ?? 0;
        _durationCtrl.text = duration.toString();
      });
    }
  }

  // ================= PICK COVER =================
  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result?.files.single.path != null) {
      setState(() {
        coverImage = File(result!.files.single.path!);
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> _submit() async {
    try {
      setState(() => isSubmitting = true);

      await _songService.updateSong(
        songId: widget.songId,
        title: _titleCtrl.text,
        genreId: selectedGenre!.genreId!,
        artistIds: [selectedArtist!.artistId!],
        albumId: selectedAlbum?.albumId,
        duration: duration,
        lyrics: _lyricsCtrl.text,
        isActive: isActive,
        musicFile: musicFile,
        coverImage: coverImage,
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          'Cập nhật bài hát',
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
            _infoSection(),
            const SizedBox(height: 20),
            _lyricsSection(),
            const SizedBox(height: 20),
            _uploadMusicSection(),
            // player
            AudioPreviewPlayer(
              localFile: musicFile,
              networkUrl: oldMusicUrl,
            ),
            const SizedBox(height: 20),
            _uploadImageSection(),
            const SizedBox(height: 20),
            _activeSection(),
            const SizedBox(height: 28),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  // ================= SECTIONS =================
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
          _albumDropdown(),
          const SizedBox(height: 14),
          _input(
            _durationCtrl,
            'Duration (giây)',
            enabled: false,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
  //  Lyric
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

  Widget _uploadMusicSection() {
    String text;
    if (musicFile != null) {
      text = 'File mới: ${musicFile!.path.split('/').last}';
    } else if (oldMusicUrl != null) {
      text = 'File hiện tại: ${oldMusicUrl!.split('/').last}';
    } else {
      text = 'Click để upload file nhạc';
    }

    return _card(
      title: 'File nhạc',
      subtitle: 'Giữ nguyên nếu không upload',
      child: _uploadArea(Icons.music_note, text, _pickMusicFile),
    );
  }

  Widget _uploadImageSection() {
    return _card(
      title: 'Upload ảnh cover',
      subtitle: 'Giữ nguyên nếu không upload',
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
          child: coverImage != null
              ? Image.file(coverImage!, fit: BoxFit.cover) // hiển thị cover cũ
              : oldCoverUrl != null
              ? Image.network(oldCoverUrl!, fit: BoxFit.cover)
              : _emptyCover(),
        ),
      ),
    );
  }

  Widget _activeSection() {
    return _card(
      title: 'Trạng thái',
      child: SwitchListTile(
        title: const Text('Kích hoạt bài hát'),
        value: isActive,
        onChanged: (v) => setState(() => isActive = v),
      ),
    );
  }

  // ================= COMMON WIDGETS =================
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
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Cập nhật',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

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
                style:
                const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String hint,
      {TextInputType keyboardType = TextInputType.text,
        bool enabled = true}) {
    return TextField(
      controller: c,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) label,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items
              .map((e) =>
              DropdownMenuItem(value: e, child: Text(label(e))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _genreDropdown() => _dropdown(
    value: selectedGenre,
    hint: 'Thể loại',
    items: genres,
    label: (e) => e.name,
    onChanged: (v) => setState(() => selectedGenre = v),
  );

  Widget _artistDropdown() => _dropdown(
    value: selectedArtist,
    hint: 'Ca sĩ',
    items: artists,
    label: (e) => e.name,
    onChanged: (v) => setState(() => selectedArtist = v),
  );

  Widget _albumDropdown() => _dropdown(
    value: selectedAlbum,
    hint: 'Album (không bắt buộc)',
    items: albums,
    label: (e) => e.title,
    onChanged: (v) => setState(() => selectedAlbum = v),
  );

  Widget _uploadArea(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8DB27C), style: BorderStyle.solid,),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF8DB27C)),
            const SizedBox(height: 10),
            Text(text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _emptyCover() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: Color(0xFF8DB27C)),
          SizedBox(height: 10),
          Text('Click để upload ảnh',
              style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
