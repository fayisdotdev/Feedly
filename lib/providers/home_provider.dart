import 'dart:convert';
import 'package:feedly/models/feeds/feed_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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

  /// Fetch categories from API
 Future<void> fetchCategories() async {
  final url = '$baseUrl/category_list';
  debugPrint('📡 [HomeProvider] Fetching categories from: $url');

  try {
    final res = await http.get(Uri.parse(url));
    debugPrint('📥 [HomeProvider] Category response status: ${res.statusCode}');
    debugPrint('📥 [HomeProvider] Category response body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final jsonBody = jsonDecode(res.body);
      categories = CategoryModel.listFromJson(jsonBody['categories']);
      debugPrint('✅ [HomeProvider] Parsed ${categories.length} categories');
      notifyListeners();
    } else {
      debugPrint('⚠️ [HomeProvider] Failed to fetch categories');
    }
  } catch (e) {
    debugPrint('❌ [HomeProvider] Error fetching categories: $e');
  }
}

Future<void> fetchFeeds() async {
  final url = '$baseUrl/home';
  debugPrint('📡 [HomeProvider] Fetching feeds from: $url');

  try {
    isLoading = true;
    notifyListeners();

    final res = await http.get(Uri.parse(url));
    debugPrint('📥 [HomeProvider] Feed response status: ${res.statusCode}');
    debugPrint('📥 [HomeProvider] Feed response body: ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final jsonBody = jsonDecode(res.body);
      feeds = FeedModel.listFromJson(jsonBody['results']);
      debugPrint('✅ [HomeProvider] Parsed ${feeds.length} feeds');
    } else {
      debugPrint('⚠️ [HomeProvider] Failed to fetch feeds');
    }
  } catch (e) {
    debugPrint('❌ [HomeProvider] Error fetching feeds: $e');
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  /// Play video at index
  Future<void> playVideo(int index) async {
    debugPrint('▶️ [HomeProvider] Playing video at index $index');

    // Stop previous one
    if (_videoController != null) {
      debugPrint('⏹ [HomeProvider] Stopping previous video');
      await _videoController!.pause();
      await _videoController!.dispose();
      _chewieController?.dispose();
    }

    _currentPlayingIndex = index;
    final url = feeds[index].videoUrl;
    debugPrint('📡 [HomeProvider] Video URL: $url');

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: false,
    );

    debugPrint('✅ [HomeProvider] Video initialized & playing');
    notifyListeners();
  }

  void stopVideo() {
    debugPrint('⏹ [HomeProvider] Stopping video playback');
    _currentPlayingIndex = null;
    _videoController?.pause();
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🗑 [HomeProvider] Disposing HomeProvider & video controllers');
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
