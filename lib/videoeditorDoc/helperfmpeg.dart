// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

// Future<void> processVideo(String command) async {
//   await compute(_executeFFmpegCommand, command);
// }

// void _executeFFmpegCommand(String command) {
//   FFmpegKit.execute(command).then((session) {
//     print("Command execution completed!");
//   });
// }

// void compressVideo(String inputPath, String outputPath) {
//   final command = '-i $inputPath -vcodec libx264 -crf 28 $outputPath';
//   FFmpegKit.execute(command).then((session) {
//     print("Compression completed!");
//   });
// }

// void exportVideo(String videoPath, List<Map<String, dynamic>> stickers, List<Map<String, dynamic>> audioTracks, String outputPath) {
//   String stickerCommands = stickers.map((sticker) {
//     final start = sticker["start"];
//     final duration = sticker["duration"];
//     return "[0:v]overlay=x=${sticker['x']}:y=${sticker['y']}:enable='between(t,$start,${start + duration})'";
//   }).join(";");

//   String audioInputs = audioTracks.map((audio) => "-i ${audio['path']}").join(" ");
//   String audioMapping = audioTracks
//       .asMap()
//       .map((index, audio) => MapEntry(index, "[${index + 1}:a]"))
//       .values
//       .join("");

//   final command =
//       "-i $videoPath $audioInputs -filter_complex \"$stickerCommands $audioMapping amix=inputs=${audioTracks.length}:duration=first:dropout_transition=2\" -c:v libx264 -preset ultrafast $outputPath";

//   FFmpegKit.execute(command).then((session) {
//     print("Export completed!");
//   });
// }


