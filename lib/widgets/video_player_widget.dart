import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerWidget extends StatefulWidget {
  final String src;
  final bool isLocal;
  final bool autoPlay;
  final double? height;

  const VideoPlayerWidget({
    Key? key,
    required this.src,
    this.isLocal = false,
    this.autoPlay = false,
    this.height,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      if (widget.isLocal) {
        _controller = VideoPlayerController.file(File(widget.src));
      } else {
        _controller = VideoPlayerController.network(widget.src);
      }

      await _controller!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: widget.autoPlay,
        looping: false,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: true,
      );

      setState(() => _initialized = true);
    } catch (e) {
      debugPrint('VideoPlayerWidget init error: $e');
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return SizedBox(
        height: widget.height ?? 220,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height:
          widget.height ??
          _controller!.value.size.height *
              (MediaQuery.of(context).size.width /
                  (_controller!.value.size.width == 0
                      ? 1
                      : _controller!.value.size.width)),
      child: Chewie(controller: _chewieController!),
    );
  }
}
