import 'package:chewie/chewie.dart';
import 'package:feedly/core/providers/feed_provider.dart';
import 'package:feedly/widgets/feed_card.dart';
import 'package:feedly/widgets/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final homeProvider = Provider.of<FeedProvider>(context, listen: false);
    homeProvider.fetchHomeData().then((_) {
      homeProvider.sortCategoriesByFeedCount(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, provider, _) {
        List filteredFeeds = provider.feeds;
        if (selectedCategoryId != null && provider.categories.isNotEmpty) {
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
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundDark,
            title: const Text(
              'Feedly',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : RefreshIndicator(
                  color: AppColors.accent,
                  onRefresh: () async {
                    await provider.fetchHomeData();
                    provider.sortCategoriesByFeedCount();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Category Chips ---
                        if (provider.categories.isNotEmpty)
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: provider.categories.length + 1,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _buildCategoryChip(
                                    label: 'All',
                                    selected: selectedCategoryId == null,
                                    onTap: () {
                                      setState(() => selectedCategoryId = null);
                                    },
                                  );
                                }
                                final cat = provider.categories[index - 1];
                                return _buildCategoryChip(
                                  label: cat.name,
                                  selected: selectedCategoryId == cat.id,
                                  onTap: () {
                                    setState(() => selectedCategoryId = cat.id);
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 12),

                        // --- Feed List ---
                        if (filteredFeeds.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                "No feeds found 🪶",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
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
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child:
                                    isPlaying &&
                                        provider.chewieController != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: AspectRatio(
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
                                      )
                                    : FeedCard(
                                        feed: feed,
                                        onPlay: () => provider.playVideo(index),
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

  Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        backgroundColor: selected
            ? AppColors.accent
            : AppColors.backgroundLight,
        side: BorderSide(
          color: selected
              ? AppColors.accent.withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
