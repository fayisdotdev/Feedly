import 'dart:convert';
import 'dart:io';
import 'package:feedly/models/feeds/feeds_models.dart' as unified;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';



class FeedProvider with ChangeNotifier {
  final String baseUrl = 'https://frijo.noviindus.in/api';

  // Home data
  List<unified.CategoryModelUnified> categories = [];
  List<unified.FeedModelUnified> feeds = [];
  bool isLoadingHome = false;
  bool isLoadingCategories = false;

  // Upload
  final Dio _dio = Dio();
  unified.FeedUploadModelUnified upload = unified.FeedUploadModelUnified(
    desc: '',
    categoryIds: [],
  );
  bool isUploading = false;
  double uploadProgress = 0;
  VideoPlayerController? uploadVideoController;

  // User feeds (paginated)
  List<unified.UserFeedModelUnified> userFeeds = [];
  int userFeedsPage = 1;
  bool isLoadingUserFeeds = false;
  bool userFeedsHasMore = true;

  // Video playback
  int? _currentPlayingIndex;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  int? get currentPlayingIndex => _currentPlayingIndex;
  ChewieController? get chewieController => _chewieController;

  // Local caching
  final String fileName = 'home_data.json';

  String? token;

  // ---------------- Home & Categories ----------------
  Future<void> fetchCategories() async {
    final url = '$baseUrl/category_list';
    debugPrint('📡 [FeedProvider] Fetching categories from: $url');
    isLoadingCategories = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final jsonBody = jsonDecode(res.body);
        // parse using unified models and store unified types
        categories = unified.CategoryModelUnified.listFromJson(
          jsonBody['categories'] ?? [],
        );
        isLoadingCategories = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [FeedProvider] Error fetching categories: $e');
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeeds() async {
    final url = '$baseUrl/home';
    debugPrint('📡 [FeedProvider] Fetching feeds from: $url');

    try {
      isLoadingHome = true;
      notifyListeners();

      final res = await http.get(Uri.parse(url));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final jsonBody = jsonDecode(res.body);
        // parse using unified feed model and store unified types
        feeds = unified.FeedModelUnified.listFromJson(
          jsonBody['results'] ?? [],
        );
      }
    } catch (e) {
      debugPrint('❌ [FeedProvider] Error fetching feeds: $e');
    } finally {
      isLoadingHome = false;
      notifyListeners();
    }
  }

  Future<void> fetchHomeData() async {
    await fetchCategories();
    await fetchFeeds();
    await saveDataToFile();
  }

  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

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

  // ---------------- Video playback ----------------
  Future<void> playVideo(int index) async {
    debugPrint('▶️ [FeedProvider] Playing video at index $index');
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

  void stopVideo() {
    _currentPlayingIndex = null;
    _videoController?.pause();
    notifyListeners();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    uploadVideoController?.dispose();
    super.dispose();
  }

  // ---------------- Upload ----------------
  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    final file = File(video.path);

    if (!video.path.endsWith('.mp4')) {
      throw Exception('Only MP4 videos allowed.');
    }

    // initialize preview controller similar to original upload provider
    uploadVideoController?.dispose();
    uploadVideoController = VideoPlayerController.file(file);
    await uploadVideoController!.initialize();

    final duration = uploadVideoController!.value.duration;
    if (duration.inMinutes > 5) {
      uploadVideoController?.dispose();
      uploadVideoController = null;
      throw Exception('Maximum duration allowed is 5 minutes.');
    }

    upload.videoPath = file.path;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    upload.imagePath = image.path;
    notifyListeners();
  }

  void setDescription(String desc) {
    upload.desc = desc;
    notifyListeners();
  }

  void setCategories(List<String> categoryIds) {
    upload.categoryIds = categoryIds;
    notifyListeners();
  }

  Future<void> uploadFeed() async {
    if (upload.videoPath == null ||
        upload.imagePath == null ||
        upload.desc.isEmpty ||
        upload.categoryIds.isEmpty) {
      throw Exception('All fields are required.');
    }

    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(upload.videoPath!),
      'image': await MultipartFile.fromFile(upload.imagePath!),
      'desc': upload.desc,
      'category': upload.categoryIds,
    });

    try {
      isUploading = true;
      uploadProgress = 0;
      notifyListeners();

      final response = await _dio.post(
        '$baseUrl/my_feed',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        onSendProgress: (sent, total) {
          uploadProgress = sent / total;
          notifyListeners();
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        upload = unified.FeedUploadModelUnified(desc: '', categoryIds: []);
        uploadVideoController?.dispose();
        uploadVideoController = null;
        uploadProgress = 0;
        isUploading = false;
        notifyListeners();
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      isUploading = false;
      uploadProgress = 0;
      notifyListeners();
      rethrow;
    }
  }

  // Backwards-compatible getter used by UI
  bool get isLoading => isLoadingHome;

  /// Sort categories by the number of feeds that reference the category title
  void sortCategoriesByFeedCount() {
    final Map<String, int> feedCountMap = {};

    for (var cat in categories) {
      feedCountMap[cat.id] = feeds
          .where(
            (feed) =>
                feed.description.toLowerCase().contains(cat.name.toLowerCase()),
          )
          .length;
    }

    categories.sort(
      (a, b) => (feedCountMap[b.id] ?? 0).compareTo(feedCountMap[a.id] ?? 0),
    );

    debugPrint('📂 Categories sorted by feed count:');
    for (var cat in categories) {
      debugPrint('${cat.name} -> ${feedCountMap[cat.id] ?? 0} feeds');
    }
    notifyListeners();
  }

  // ---------------- User feeds (paginated) ----------------
  Future<void> fetchUserFeeds({bool refresh = false}) async {
    if (isLoadingUserFeeds) return;

    if (refresh) {
      userFeedsPage = 1;
      userFeeds.clear();
      userFeedsHasMore = true;
    }

    if (!userFeedsHasMore) return;

    if (token == null || token!.isEmpty) {
      throw Exception('Unauthorized. Please login.');
    }

    isLoadingUserFeeds = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/my_feed?page=$userFeedsPage');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final unifiedList = unified.UserFeedModelUnified.listFromJson(
          data['results'] ?? [],
        );

        final List<unified.UserFeedModelUnified> fetched = unifiedList;

        if (fetched.isEmpty) {
          userFeedsHasMore = false;
        } else {
          userFeeds.addAll(fetched);
          userFeedsPage++;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized.');
      } else {
        throw Exception('Failed to fetch feeds: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching user feeds: $e');
      rethrow;
    } finally {
      isLoadingUserFeeds = false;
      notifyListeners();
    }
  }
}
