// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';
//
// import '../../model/OverlayItem.dart';
// import '../../model/VideoClip.dart';
// import '../../model/audioItem.dart';
//
// class VideoEditorState {
//   final VideoPlayerController? videoController;
//   final List<VideoClip> videoClips;
//   final List<OverlayItem> overlays;
//   final List<AudioItem> audioFiles;
//   final bool isPlaying;
//   final double timelinePosition;
//   final double totalVideoDuration;
//   final String selectedFilter;
//   final String selectedTransition;
//
//   VideoEditorState({
//     this.videoController,
//     this.videoClips = const [],
//     this.overlays = const [],
//     this.audioFiles = const [],
//     this.isPlaying = false,
//     this.timelinePosition = 0.0,
//     this.totalVideoDuration = 0.0,
//     this.selectedFilter = 'Normal',
//     this.selectedTransition = 'Fade',
//   });
//
//   VideoEditorState copyWith({
//     VideoPlayerController? videoController,
//     List<VideoClip>? videoClips,
//     List<OverlayItem>? overlays,
//     List<AudioItem>? audioFiles,
//     bool? isPlaying,
//     double? timelinePosition,
//     double? totalVideoDuration,
//     String? selectedFilter,
//     String? selectedTransition,
//   }) {
//     return VideoEditorState(
//       videoController: videoController ?? this.videoController,
//       videoClips: videoClips ?? this.videoClips,
//       overlays: overlays ?? this.overlays,
//       audioFiles: audioFiles ?? this.audioFiles,
//       isPlaying: isPlaying ?? this.isPlaying,
//       timelinePosition: timelinePosition ?? this.timelinePosition,
//       totalVideoDuration: totalVideoDuration ?? this.totalVideoDuration,
//       selectedFilter: selectedFilter ?? this.selectedFilter,
//       selectedTransition: selectedTransition ?? this.selectedTransition,
//     );
//   }
// }