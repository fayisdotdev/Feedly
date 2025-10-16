import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';
import 'package:feedly/providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategoryId;

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
        // Filter feeds by selected category (simple demo: check if category name is in description)
        List filteredFeeds = provider.feeds;
        if (selectedCategoryId != null) {
          final selectedCategory = provider.categories.firstWhere(
            (cat) => cat.id == selectedCategoryId,
            orElse: () => provider.categories.first,
          );
          filteredFeeds = provider.feeds
              .where(
                (feed) => feed.description.toLowerCase().contains(
                  selectedCategory.name.toLowerCase(),
                ),
              )
              .toList();
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(title: const Text('Home'), centerTitle: true),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchHomeData();
                    provider.sortCategoriesByFeedCount();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category List
                        if (provider.categories.isNotEmpty)
                          SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: provider.categories.length + 1,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // "All" category
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCategoryId = null;
                                      });
                                    },
                                    child: Chip(
                                      label: const Text('All'),
                                      backgroundColor:
                                          selectedCategoryId == null
                                          ? Colors.blue[200]
                                          : Colors.white,
                                      side: const BorderSide(
                                        color: Colors.black12,
                                      ),
                                    ),
                                  );
                                }
                                final cat = provider.categories[index - 1];
                                final isSelected = selectedCategoryId == cat.id;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryId = cat.id;
                                    });
                                  },
                                  child: Chip(
                                    label: Text(cat.name),
                                    backgroundColor: isSelected
                                        ? Colors.blue[200]
                                        : Colors.white,
                                    side: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Feed List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredFeeds.length,
                          itemBuilder: (context, index) {
                            final feed = filteredFeeds[index];
                            final isPlaying =
                                provider.currentPlayingIndex == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
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
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                            child: Image.network(
                                              feed.thumbnailUrl,
                                              height: 220,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if (isPlaying &&
                                            provider.chewieController != null)
                                          AspectRatio(
                                            aspectRatio: provider
                                                .chewieController!
                                                .videoPlayerController
                                                .value
                                                .aspectRatio,
                                            child: Chewie(
                                              controller:
                                                  provider.chewieController!,
                                            ),
                                          ),
                                        if (!isPlaying)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.play_circle_fill,
                                              size: 64,
                                              color: Colors.white,
                                            ),
                                            onPressed: () =>
                                                provider.playVideo(index),
                                          ),
                                      ],
                                    ),
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            feed.userAvatar.startsWith('http')
                                            ? NetworkImage(feed.userAvatar)
                                            : const AssetImage(
                                                    'assets/images/avatar_placeholder.png',
                                                  )
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
