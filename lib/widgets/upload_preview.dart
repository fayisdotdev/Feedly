import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class UploadPreview extends StatelessWidget {
  final String? imagePath;
  final String? videoPath;
  final VideoPlayerController? videoController;

  const UploadPreview({
    Key? key,
    this.imagePath,
    this.videoPath,
    this.videoController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (videoPath != null &&
        videoController != null &&
        videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: VideoPlayer(videoController!),
      );
    }

    if (imagePath != null) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(child: Text('No preview')),
    );
  }
}
