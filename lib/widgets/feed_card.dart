import 'dart:io';
import 'package:feedly/widgets/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:feedly/models/feeds/feeds_models.dart' as unified;

class FeedCard extends StatelessWidget {
  final unified.FeedModelUnified feed;
  final VoidCallback? onPlay;
  final double? height;

  const FeedCard({
    super.key,
    required this.feed,
    this.onPlay,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardDark,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Thumbnail Preview ---
          Stack(
            alignment: Alignment.center,
            children: [
              _buildThumbnail(),
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 60,
                  color: AppColors.accent,
                ),
                onPressed: onPlay,
              ),
            ],
          ),

          // --- Feed Info ---
          ListTile(
            leading: CircleAvatar(
              backgroundImage: feed.userAvatar.startsWith('http')
                  ? NetworkImage(feed.userAvatar)
                  : const AssetImage('assets/images/avatar_placeholder.png')
                      as ImageProvider,
            ),
            title: Text(
              feed.userName,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              feed.description,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (feed.thumbnailUrl.isNotEmpty && !feed.thumbnailUrl.startsWith('/')) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          feed.thumbnailUrl,
          height: height ?? 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (feed.thumbnailUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.file(
          File(feed.thumbnailUrl),
          height: height ?? 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        height: height ?? 220,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
      );
    }
  }
}
