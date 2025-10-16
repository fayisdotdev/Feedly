import 'dart:convert';
import 'dart:io';
import 'package:feedly/models/feeds/feed_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';

class HomeProvider with ChangeNotifier {
  final String baseUrl = 'https://frijo.noviindus.in/api';

  List<CategoryModel> categories = [];
  List<FeedModel> feeds = [];

  bool isLoading = false;
  int? _currentPlayingIndex;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  int? get currentPlayingIndex => _currentPlayingIndex;
  ChewieController? get chewieController => _chewieController;

  final String fileName = 'home_data.json';

  /// Fetch categories from API
  Future<void> fetchCategories() async {
    final url = '$baseUrl/category_list';
    debugPrint('📡 [HomeProvider] Fetching categories from: $url');

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final jsonBody = jsonDecode(res.body);
        categories = CategoryModel.listFromJson(jsonBody['categories'] ?? []);
        debugPrint('✅ [HomeProvider] Parsed ${categories.length} categories');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [HomeProvider] Error fetching categories: $e');
    }
  }

  /// Fetch feeds from API
  Future<void> fetchFeeds() async {
    final url = '$baseUrl/home';
    debugPrint('📡 [HomeProvider] Fetching feeds from: $url');

    try {
      isLoading = true;
      notifyListeners();

      final res = await http.get(Uri.parse(url));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final jsonBody = jsonDecode(res.body);
        feeds = FeedModel.listFromJson(jsonBody['results'] ?? []);
        debugPrint('✅ [HomeProvider] Parsed ${feeds.length} feeds');
      }
    } catch (e) {
      debugPrint('❌ [HomeProvider] Error fetching feeds: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch both from API and save to local file
  Future<void> fetchHomeData() async {
    await fetchCategories();
    await fetchFeeds();
    await saveDataToFile();
  }

  /// Get file path in device storage
  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Save fetched data to local JSON file
  Future<void> saveDataToFile() async {
    try {
      final file = await _localFile;
      final data = {
        'categories': categories.map((e) => e.toJson()).toList(),
        'feeds': feeds.map((e) => e.toJson()).toList(),
      };
      await file.writeAsString(jsonEncode(data));
      debugPrint('✅ Data saved at ${file.path}');
    } catch (e) {
      debugPrint('❌ Error saving data: $e');
    }
  }

  /// Load data from local file
  Future<void> loadDataFromFile() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return;

      final jsonString = await file.readAsString();
      final jsonBody = jsonDecode(jsonString);

      categories = CategoryModel.listFromJson(jsonBody['categories'] ?? []);
      feeds = FeedModel.listFromJson(jsonBody['feeds'] ?? []);

      debugPrint('✅ Loaded ${categories.length} categories and ${feeds.length} feeds from file');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading data from file: $e');
    }
  }

  /// Play video at index
  Future<void> playVideo(int index) async {
    debugPrint('▶️ [HomeProvider] Playing video at index $index');

    if (_videoController != null) {
      await _videoController!.pause();
      await _videoController!.dispose();
      _chewieController?.dispose();
    }

    _currentPlayingIndex = index;
    final url = feeds[index].videoUrl;
    if (url.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: false,
    );

    notifyListeners();
  }

  /// Stop current video
  void stopVideo() {
    _currentPlayingIndex = null;
    _videoController?.pause();
    notifyListeners();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
