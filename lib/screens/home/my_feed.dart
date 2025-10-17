import 'package:feedly/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feedly/core/providers/feed_provider.dart';
import 'package:feedly/models/feeds/feeds_models.dart' as unified;
import 'package:feedly/widgets/feed_card.dart';
import 'package:feedly/widgets/video_player_widget.dart';
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
      final authProvider =
          Provider.of<AuthProviderCompact>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);

      if (authProvider.accessToken != null &&
          authProvider.accessToken!.isNotEmpty) {
        feedProvider.token = authProvider.accessToken;
        feedProvider.fetchUserFeeds();
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
                  provider.userFeeds.length + (provider.userFeedsHasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.userFeeds.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final unified.UserFeedModelUnified feed =
                    provider.userFeeds[index];

                // FeedCard now handles showing either image or video
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: FeedCard(
                    feed: unified.FeedModelUnified(
                      id: feed.id.toString(),
                      thumbnailUrl: feed.image ?? '',
                      videoUrl: feed.video ?? '',
                      description: feed.description,
                      userName: 'You',
                      userAvatar: 'assets/images/avatar_placeholder.png',
                    ),
                    height: feed.video != null ? 220 : 140,
                    onPlay: feed.video != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerWidget(
                                  src: feed.video!,
                                  autoPlay: true,
                                ),
                              ),
                            );
                          }
                        : null,
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
