import 'dart:io';

class AudioItem {
  final File file;
  double startTime;
  double duration;

  AudioItem({
    required this.file,
    this.startTime = 0.0,
    this.duration = 10.0,
  });
}