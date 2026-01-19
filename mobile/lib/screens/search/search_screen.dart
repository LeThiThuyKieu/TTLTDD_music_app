import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/song_model.dart';
import '../../models/artist_model.dart';
import '../../models/album_model.dart';
import '../../models/genre_model.dart';
import '../../services/search_service.dart';

import 'widgets/browse_categories.dart';
import 'widgets/recent_searches.dart';
import 'widgets/no_results.dart';
import 'widgets/search_results.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  // KHAI BÁO
      // Nội dung ttfield
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); //trang thái focus

  List<String> _recentSearches = []; // luu ls tìm kiếm gần đây
  String _query = ''; // keyword câ search
  bool _isLoading = false;

  // Lưu kết quả tìm kiếm (parse sang model)
  List<SongModel> _songs = [];
  List<ArtistModel> _artists = [];
  List<AlbumModel> _albums = [];
  List<GenreModel> _genres = [];

  late TabController _tabController;  // tab hiển thị

  /// ===== ANIMATION CHO INPUT =====
  late AnimationController _inputAnimController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this);

    // animation phóng to khi focus
    _inputAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _inputAnimController,
        curve: Curves.easeOut,
      ),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _inputAnimController.forward();
      } else {
        _inputAnimController.reverse();
      }
      setState(() {});
    });

    _loadRecentSearches();

    // update query liên tục khi user nhập
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }
  // Load ds lsu tìm kiếm từ SharedPreferences khi screen mở
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }
  // Thêm query vừa tìm kiếm vào đầu danh sách recent. ( 10 item)
  Future<void> _addToRecentSearches(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('recent_searches') ?? [];
    list.remove(query);
    list.insert(0, query);
    if (list.length > 10) list = list.sublist(0, 10);
    await prefs.setStringList('recent_searches', list);
    setState(() => _recentSearches = list);
  }
  // Xoá all lsu tìm kiếm
  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches.clear());
  }
  // Gọi API tìm kiếm
  Future<void> _performSearch() async {
    if (_query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Gọi service tìm kiếm
      final results = await SearchService().searchAll(_query); //ApiService.get("/search?q=<query>")
      //  Lấy kết quả : ds song và artist
      setState(() {
        _songs = results['songs'] ?? [];
        _artists = results['artists'] ?? [];
        _albums = results['albums'] ?? [];
        _genres = results['genres'] ?? [];
        _isLoading = false;
      });
      await _addToRecentSearches(_query);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm: $e')),
      );
    }
  }

  @override
  void dispose() {
    _inputAnimController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBrowse = _query.isEmpty && !_focusNode.hasFocus;
    final showRecent = _focusNode.hasFocus && _query.isEmpty;
    final showResults = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: _buildSearchInput(),
      ),
      /// ================= BODY =================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildBody(showBrowse, showRecent, showResults),
      ),
    );
  }

  /// ================= SEARCH INPUT =================
  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 20, 8),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: _focusNode.hasFocus
                ? const Color(0xFFE8F5E9) // xanh nhạt khi focus
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? const Color(0xFF4CAF50)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'Bạn muốn nghe gì?',
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: _focusNode.hasFocus
                    ? const Color(0xFF4CAF50)
                    : Colors.grey,
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
                  : null,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= BODY STATE =================
  Widget _buildBody(bool showBrowse, bool showRecent, bool showResults) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (showBrowse) {
      return const BrowseCategoriesWidget(key: ValueKey('browse'));
    }

    if (showRecent) {
      return RecentSearchesWidget(
        key: const ValueKey('recent'),
        recentSearches: _recentSearches,
        onClearAll: _clearRecentSearches,
        onItemTap: (q) {
          _searchController.text = q;
          _performSearch();
        },
        onDeleteItem: (q) async {
          final prefs = await SharedPreferences.getInstance();
          _recentSearches.remove(q);
          await prefs.setStringList('recent_searches', _recentSearches);
          setState(() {});
        },
      );
    }

    if (showResults && _songs.isEmpty && _artists.isEmpty) {
      return const NoResultsWidget(key: ValueKey('no-results'));
    }

    return SearchResultsWidget(
      key: const ValueKey('results'),
      tabController: _tabController,
      songs: _songs,
      artists: _artists,
      albums: _albums,
      genres: _genres,
    );
  }
}
