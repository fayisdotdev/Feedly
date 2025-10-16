import 'dart:convert';
import 'dart:io';
import 'package:feedly/models/feeds/feed_upload_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class AddFeedProvider with ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = 'https://frijo.noviindus.in/api';
  String? token; // Set this after login

  FeedUploadModel feed = FeedUploadModel(desc: '', categoryIds: []);

  VideoPlayerController? videoController;

  bool isUploading = false;
  double uploadProgress = 0;

  List<CategoryModel> categories = [];
  bool isLoadingCategories = false;

  /// Pick video from gallery
  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    final file = File(video.path);

    if (!video.path.endsWith('.mp4')) {
      throw Exception('Only MP4 videos allowed.');
    }

    videoController?.dispose();
    videoController = VideoPlayerController.file(file);
    await videoController!.initialize();

    final duration = videoController!.value.duration;
    if (duration.inMinutes > 5) {
      videoController?.dispose();
      throw Exception('Maximum duration allowed is 5 minutes.');
    }

    feed.videoPath = file.path;
    notifyListeners();
  }

  /// Pick thumbnail image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    feed.imagePath = image.path;
    notifyListeners();
  }

  /// Set description
  void setDescription(String desc) {
    feed.desc = desc;
    notifyListeners();
  }

  /// Set selected categories
void setCategories(List<String> categoryIds) {
  feed.categoryIds = categoryIds;
  notifyListeners();
}


  /// Fetch categories from API
  Future<void> fetchCategories() async {
  isLoadingCategories = true;
  notifyListeners();

  try {
    final url = Uri.parse('$baseUrl/category_list');
    debugPrint('📡 Fetching categories from: $url');

    final response = await http.get(url);
    debugPrint('📄 Response: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final listData = (data['categories'] ?? []).map((c) {
        return {
          'id': c['id'].toString(),
          'name': c['title'], // map API title to our model name
          'image': c['image'],
        };
      }).toList();

      categories = CategoryModel.listFromJson(listData);

      debugPrint('✅ Fetched ${categories.length} categories');
      for (var cat in categories) {
        debugPrint('📂 ${jsonEncode(cat.toJson())}');
      }
    } else {
      throw Exception('Failed to fetch categories: ${response.statusCode}');
    }
  } catch (e) {
    categories = [];
    debugPrint('❌ Error fetching categories: $e');
  } finally {
    isLoadingCategories = false;
    notifyListeners();
  }
}


  /// Upload feed to API
  Future<void> uploadFeed() async {
    if (feed.videoPath == null ||
        feed.imagePath == null ||
        feed.desc.isEmpty ||
        feed.categoryIds.isEmpty) {
      throw Exception('All fields are required.');
    }

    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(feed.videoPath!),
      'image': await MultipartFile.fromFile(feed.imagePath!),
      'desc': feed.desc,
      'category': feed.categoryIds,
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

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202 ) {
        feed = FeedUploadModel(desc: '', categoryIds: []);
        videoController?.dispose();
        videoController = null;
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
}
