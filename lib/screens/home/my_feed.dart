import 'package:feedly/core/providers/auth_provider.dart';
import 'package:feedly/core/providers/feed_provider.dart';
import 'package:feedly/models/feeds/user_feeds_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyFeedScreen extends StatefulWidget {
  const MyFeedScreen({super.key});

  @override
  State<MyFeedScreen> createState() => _MyFeedScreenState();
}

class _MyFeedScreenState extends State<MyFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProviderCompact>(
        context,
        listen: false,
      );
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);

      if (authProvider.accessToken != null &&
          authProvider.accessToken!.isNotEmpty) {
        feedProvider.token = authProvider.accessToken;
        feedProvider.fetchUserFeeds();
      } else {
        debugPrint('No access token available. Redirect to login.');
      }

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          feedProvider.fetchUserFeeds();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feeds')),
      body: Consumer<FeedProvider>(
        builder: (context, provider, _) {
          if (provider.userFeeds.isEmpty && provider.isLoadingUserFeeds) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.userFeeds.isEmpty) {
            return const Center(child: Text('No feeds yet.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchUserFeeds(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  provider.userFeeds.length +
                  (provider.userFeedsHasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.userFeeds.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final UserFeedModel feed = provider.userFeeds[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image / Video preview
                      if (feed.image != null || feed.video != null)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            feed.image != null
                                ? Image.network(
                                    feed.image!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox.shrink(),
                            if (feed.video != null)
                              const Icon(
                                Icons.play_circle_outline,
                                size: 64,
                                color: Colors.white70,
                              ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description
                            Text(
                              feed.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            // Timestamp
                            Text(
                              formatTimestamp(feed.createdAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
