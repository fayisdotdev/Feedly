import 'dart:convert';
import 'package:feedly/models/feeds/user_feeds_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserFeedProvider with ChangeNotifier {
  final String baseUrl = 'https://frijo.noviindus.in/api';
  String? token;

  List<UserFeedModel> feeds = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  /// Fetch user feeds with pagination
  Future<void> fetchUserFeeds({bool refresh = false}) async {
    if (isLoading) {
      debugPrint('⚡ Already loading feeds, skipping fetch...');
      return;
    }

    if (refresh) {
      debugPrint('🔄 Refreshing feeds...');
      page = 1;
      feeds.clear();
      hasMore = true;
    }

    if (!hasMore) {
      debugPrint('✅ No more feeds to load.');
      return;
    }

    if (token == null || token!.isEmpty) {
      debugPrint('❌ Token missing. User unauthorized.');
      throw Exception('Unauthorized. Please login again.');
    }

    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/my_feed?page=$page');
      debugPrint('🌐 Fetching feeds from $url');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      debugPrint('📩 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('📦 Response data: $data');

        // ✅ Use results instead of feeds
        final List<UserFeedModel> fetchedFeeds =
            UserFeedModel.listFromJson(data['results'] ?? []);

        if (fetchedFeeds.isEmpty) {
          debugPrint('ℹ️ No feeds returned from API.');
          hasMore = false;
        } else {
          feeds.addAll(fetchedFeeds);
          page++;
          debugPrint('✅ Fetched ${fetchedFeeds.length} feeds. Total: ${feeds.length}');
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Unauthorized. Please login again.');
        throw Exception('Unauthorized. Please login again.');
      } else {
        debugPrint('❌ Failed to fetch feeds: ${response.statusCode}');
        throw Exception('Failed to fetch feeds: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching user feeds: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
