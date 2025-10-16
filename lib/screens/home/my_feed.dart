import 'package:feedly/core/providers/auth_provider.dart';
import 'package:feedly/core/providers/feed_provider.dart';
import 'package:feedly/models/feeds/feeds_models.dart' as unified;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:feedly/widgets/feed_card.dart';
import 'package:feedly/widgets/video_player_widget.dart';

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

                final unified.UserFeedModelUnified feed =
                    provider.userFeeds[index];

                // Reuse FeedCard for a consistent look. If it's a user-owned post with video, show a small preview above the card.
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (feed.video != null)
                        SizedBox(
                          height: 220,
                          child: VideoPlayerWidget(
                            src: feed.video!,
                            isLocal: false,
                            autoPlay: false,
                          ),
                        )
                      else if (feed.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            feed.image!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      FeedCard(
                        feed: unified.FeedModelUnified(
                          id: feed.id.toString(),
                          thumbnailUrl: feed.image ?? '',
                          videoUrl: feed.video ?? '',
                          description: feed.description,
                          userName: 'You',
                          userAvatar: 'assets/images/avatar_placeholder.png',
                        ),
                        onPlay: null,
                        height: 140,
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
