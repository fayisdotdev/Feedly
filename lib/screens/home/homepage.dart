import 'package:feedly/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Home'),
            centerTitle: true,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => await provider.fetchHomeData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories
                        if (provider.categories.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: provider.categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final cat = provider.categories[index];
                                return Chip(
                                  label: Text(cat.name),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.black12),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Feeds
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.feeds.length,
                          itemBuilder: (context, index) {
                            final feed = provider.feeds[index];
                            final isPlaying = provider.currentPlayingIndex == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (!isPlaying)
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                            child: feed.thumbnailUrl.isNotEmpty
                                                ? Image.network(
                                                    feed.thumbnailUrl,
                                                    height: 220,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/images/feed_placeholder.png',
                                                    height: 220,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        if (isPlaying && provider.chewieController != null)
                                          AspectRatio(
                                            aspectRatio: provider
                                                .chewieController!
                                                .videoPlayerController
                                                .value
                                                .aspectRatio,
                                            child: Chewie(
                                              controller: provider.chewieController!,
                                            ),
                                          ),
                                        if (!isPlaying)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.play_circle_fill,
                                              size: 64,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => provider.playVideo(index),
                                          ),
                                      ],
                                    ),
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: feed.userAvatar.isNotEmpty
                                            ? NetworkImage(feed.userAvatar)
                                            : const AssetImage(
                                                    'assets/images/avatar_placeholder.png')
                                                as ImageProvider,
                                      ),
                                      title: Text(feed.userName),
                                      subtitle: Text(feed.description),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
