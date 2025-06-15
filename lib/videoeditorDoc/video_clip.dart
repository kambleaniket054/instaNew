import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoClip {
  final File file;
  final VideoPlayerController controller;
  double startTime;
  double duration;
  String transitionType;
  double fadeInDuration;
  double fadeOutDuration;

  VideoClip({
    required this.file,
    required this.controller,
    this.startTime = 0.0,
    required this.duration,
    this.transitionType = 'Fade',
    this.fadeInDuration = 1.0,
    this.fadeOutDuration = 1.0,
  });
}