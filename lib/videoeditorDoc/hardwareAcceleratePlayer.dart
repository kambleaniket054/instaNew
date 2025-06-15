import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HardwareAcceleratedPlayer extends StatefulWidget {
  final String videoPath;

  const HardwareAcceleratedPlayer({super.key, required this.videoPath});

  @override
  _HardwareAcceleratedPlayerState createState() =>
      _HardwareAcceleratedPlayerState();
}

class _HardwareAcceleratedPlayerState extends State<HardwareAcceleratedPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {});
        });
      });
    super.initState();
    // _controller =  VideoPlayerController.networkUrl(Uri.parse(
    // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))..initialize().then((_) => setState(() {}));
    // _controller = VideoPlayerController.file(File(widget.videoPath))
    // ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}
