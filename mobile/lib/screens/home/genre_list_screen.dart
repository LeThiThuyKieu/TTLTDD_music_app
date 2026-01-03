import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../models/genre_model.dart';
import '../../services/api_service.dart';

class GenreListScreen extends StatefulWidget {
  const GenreListScreen({super.key});

  @override
  State<GenreListScreen> createState() => _GenreListScreenState();
}

class _GenreListScreenState extends State<GenreListScreen> {
  final ApiService _apiService = ApiService();
  List<GenreModel> _genres = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await _apiService.get(ApiConfig.genres, includeAuth: false);

      final data = response['data'];
      if (data is List) {
        _genres = data
            .map((json) => GenreModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _genres = [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchGenres,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchGenres,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_genres.isEmpty) {
      return const Center(
        child: Text('Chưa có thể loại nào.'),
      );
    }

    return ListView.separated(
      itemCount: _genres.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final genre = _genres[index];
        final initial =
            genre.name.isNotEmpty ? genre.name[0].toUpperCase() : '?';

        return ListTile(
          leading: CircleAvatar(
            child: Text(initial),
          ),
          title: Text(genre.name),
          subtitle: genre.createdAt != null
              ? Text('Tạo lúc: ${genre.createdAt}')
              : null,
        );
      },
    );
  }
}


