import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_editor_bloc.dart';

class VideoEditorState {
  final List<VideoClip> videoClips;
  final List<AudioItem> audioFiles;
  final List<OverlayItem> overlays;
  final VideoPlayerController? videoController;
  final double totalVideoDuration;
  final double timelinePosition;
  final bool isPlaying;
  final String selectedFilter;
  final String selectedTransition;

  VideoEditorState({
    this.videoClips = const [],
    this.audioFiles = const [],
    this.overlays = const [],
    this.videoController,
    this.totalVideoDuration = 0.0,
    this.timelinePosition = 0.0,
    this.isPlaying = false,
    this.selectedFilter = 'Normal',
    this.selectedTransition = 'Fade',
  });

  VideoEditorState copyWith({
    List<VideoClip>? videoClips,
    List<AudioItem>? audioFiles,
    List<OverlayItem>? overlays,
    VideoPlayerController? videoController,
    double? totalVideoDuration,
    double? timelinePosition,
    bool? isPlaying,
    String? selectedFilter,
    String? selectedTransition,
  }) {
    return VideoEditorState(
      videoClips: videoClips ?? this.videoClips,
      audioFiles: audioFiles ?? this.audioFiles,
      overlays: overlays ?? this.overlays,
      videoController: videoController ?? this.videoController,
      totalVideoDuration: totalVideoDuration ?? this.totalVideoDuration,
      timelinePosition: timelinePosition ?? this.timelinePosition,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTransition: selectedTransition ?? this.selectedTransition,
    );
  }
}