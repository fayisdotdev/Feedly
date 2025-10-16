import 'dart:io';
import 'package:flutter/material.dart';
import 'package:feedly/models/feeds/feeds_models.dart' as unified;
// lightweight feed card; video preview handled by separate widget when needed

class FeedCard extends StatelessWidget {
  final unified.FeedModelUnified feed;
  final VoidCallback? onPlay;
  final double? height;

  const FeedCard({Key? key, required this.feed, this.onPlay, this.height})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (feed.thumbnailUrl.isNotEmpty &&
                  !feed.thumbnailUrl.startsWith('/'))
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    feed.thumbnailUrl,
                    height: height ?? 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else if (feed.thumbnailUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.file(
                    File(feed.thumbnailUrl),
                    height: height ?? 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(height: height ?? 220, color: Colors.grey[200]),

              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
                ),
                onPressed: onPlay,
              ),
            ],
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: feed.userAvatar.startsWith('http')
                  ? NetworkImage(feed.userAvatar)
                  : AssetImage('assets/images/avatar_placeholder.png')
                        as ImageProvider,
            ),
            title: Text(feed.userName),
            subtitle: Text(feed.description),
          ),
        ],
      ),
    );
  }
}
