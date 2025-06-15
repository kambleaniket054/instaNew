
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instanew/videoeditorDoc/overlay_item.dart';
import 'package:instanew/videoeditorDoc/video_editor_event.dart';
import 'package:instanew/videoeditorDoc/video_editor_state.dart';
import 'package:video_player/video_player.dart';

class VideoEditorBloc extends Bloc<VideoEditorEvent, VideoEditorState> {
  VideoEditorBloc() : super(VideoEditorState()) {
    on<AddVideoEvent>(_onAddVideo);
    on<AddAudioEvent>(_onAddAudio);
    on<AddTextOverlayEvent>(_onAddTextOverlay);
    on<AddStickerEvent>(_onAddSticker);
    on<AddEmojiStickerEvent>(_onAddEmojiSticker);
    on<UpdateOverlayPositionEvent>(_onUpdateOverlayPosition);
    on<UpdateOverlayScaleEvent>(_onUpdateOverlayScale);
    on<UpdateTextOverlayEvent>(_onUpdateTextOverlay);
    on<UpdateVideoStartTimeEvent>(_onUpdateVideoStartTime);
    on<UpdateVideoDurationEvent>(_onUpdateVideoDuration);
    on<UpdateAudioStartTimeEvent>(_onUpdateAudioStartTime);
    on<UpdateOverlayStartTimeEvent>(_onUpdateOverlayStartTime);
    on<UpdateTimelinePositionEvent>(_onUpdateTimelinePosition);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<SeekVideoEvent>(_onSeekVideo);
    on<ChangeFilterEvent>(_onChangeFilter);
    on<ChangeTransitionEvent>(_onChangeTransition);
  }

  Future<void> _onAddVideo(AddVideoEvent event, Emitter<VideoEditorState> emit) async {
    String? videoPath = event.path;
    try {
      if (videoPath == null) {
        final result = await FilePicker.platform.pickFiles(type: FileType.video);
        if (result != null) {
          videoPath = result.files.single.path;
        } else {
          print('No video selected');
          return;
        }
      }
      if (videoPath != null) {
        final controller = VideoPlayerController.file(File(videoPath));
        await controller.initialize();
        final duration = controller.value.duration.inSeconds.toDouble();
        final newClip = VideoClip(
          controller: controller,
          startTime: 0.0,
          duration: duration,
        );
        final newController = state.videoController ?? controller;
        emit(state.copyWith(
          videoClips: [...state.videoClips, newClip],
          videoController: newController,
          totalVideoDuration: state.totalVideoDuration + duration,
        ));
        print('Added video: $videoPath, duration: $duration');
      }
    } catch (e) {
      print('Error adding video: $e');
    }
  }

  Future<void> _onAddAudio(AddAudioEvent event, Emitter<VideoEditorState> emit) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      final audioPath = result.files.single.path!;
      final player = AudioPlayer();
      await player.setSourceDeviceFile(audioPath);
      final duration = (await player.getDuration())?.inSeconds.toDouble() ?? 10.0;
      final newAudio = AudioItem(
        file: File(audioPath),
        startTime: 0.0,
        duration: duration,
      );
      emit(state.copyWith(audioFiles: [...state.audioFiles, newAudio]));
    }
  }

  void _onAddTextOverlay(AddTextOverlayEvent event, Emitter<VideoEditorState> emit) {
    print('Processing AddTextOverlayEvent');
    final newOverlay = OverlayItem(
      type: 'text',
      content: 'Sample Text',
      position: Offset(50, 50),
      startTime: state.timelinePosition / 20,
      duration: 5.0,
      scale: 1.0,
      previewWidth: 720,
      previewHeight: 1280,
      fontSize: 24,
      color: Colors.white,
      hasBorder: false,
      fontStyle: FontStyle.normal,
    );
    emit(state.copyWith(overlays: [...state.overlays, newOverlay]));
    print('Added text overlay: ${newOverlay.content}, start: ${newOverlay.startTime}, duration: ${newOverlay.duration}');
  }

  void _onUpdateOverlayDuration(UpdateOverlayDurationEvent event, Emitter<VideoEditorState> emit) {
    print('Processing UpdateOverlayDurationEvent for index ${event.index}, new duration: ${event.duration}');
    final updatedOverlays = List<OverlayItem>.from(state.overlays);
    if (event.index >= 0 && event.index < updatedOverlays.length) {
      final overlay = updatedOverlays[event.index];
      updatedOverlays[event.index] = OverlayItem(
        type: overlay.type,
        content: overlay.content,
        position: overlay.position,
        startTime: overlay.startTime,
        duration: event.duration,
        scale: overlay.scale,
        previewWidth: overlay.previewWidth,
        previewHeight: overlay.previewHeight,
        fontSize: overlay.fontSize,
        color: overlay.color,
        hasBorder: overlay.hasBorder,
        fontStyle: overlay.fontStyle,
      );
      emit(state.copyWith(overlays: updatedOverlays));
      print('Updated overlay duration at index ${event.index} to ${event.duration}');
    } else {
      print('Invalid overlay index: ${event.index}');
    }
  }
  void _onAddSticker(AddStickerEvent event, Emitter<VideoEditorState> emit) {
    final newOverlay = OverlayItem(
      type: event.fromKeyboard ? 'keyboard_sticker' : 'sticker',
      content: event.path,
      position: Offset(50, 50),
      startTime: state.timelinePosition / 20,
      duration: 5.0,
      scale: 1.0,
      previewWidth: 720,
      previewHeight: 1280,
    );
    emit(state.copyWith(overlays: [...state.overlays, newOverlay]));
    print('Added sticker: ${event.path}, fromKeyboard: ${event.fromKeyboard}');
  }

  void _onAddEmojiSticker(AddEmojiStickerEvent event, Emitter<VideoEditorState> emit) {
    final newOverlay = OverlayItem(
      type: 'emoji',
      content: event.emoji,
      position: Offset(50, 50),
      startTime: state.timelinePosition / 20,
      duration: 5.0,
      scale: 1.0,
      previewWidth: 720,
      previewHeight: 1280,
    );
    emit(state.copyWith(overlays: [...state.overlays, newOverlay]));
  }

  void _onUpdateOverlayPosition(UpdateOverlayPositionEvent event, Emitter<VideoEditorState> emit) {
    final updatedOverlays = List<OverlayItem>.from(state.overlays);
    updatedOverlays[event.index] = updatedOverlays[event.index].copyWith(
      position: event.position,
      previewWidth: 720,
      previewHeight: 1280,
    );
    emit(state.copyWith(overlays: updatedOverlays));
  }

  void _onUpdateOverlayScale(UpdateOverlayScaleEvent event, Emitter<VideoEditorState> emit) {
    final updatedOverlays = List<OverlayItem>.from(state.overlays);
    updatedOverlays[event.index] = updatedOverlays[event.index].copyWith(scale: event.scale);
    emit(state.copyWith(overlays: updatedOverlays));
  }

  void _onUpdateTextOverlay(UpdateTextOverlayEvent event, Emitter<VideoEditorState> emit) {
    final updatedOverlays = List<OverlayItem>.from(state.overlays);
    updatedOverlays[event.index] = updatedOverlays[event.index].copyWith(
      content: event.content,
      fontSize: event.fontSize,
      color: event.color,
      hasBorder: event.hasBorder,
      fontStyle: event.fontStyle,
    );
    emit(state.copyWith(overlays: updatedOverlays));
  }

  void _onUpdateVideoStartTime(UpdateVideoStartTimeEvent event, Emitter<VideoEditorState> emit) {
    final updatedClips = List<VideoClip>.from(state.videoClips);
    updatedClips[event.index] = updatedClips[event.index].copyWith(startTime: event.startTime);
    emit(state.copyWith(videoClips: updatedClips));
  }

  void _onUpdateVideoDuration(UpdateVideoDurationEvent event, Emitter<VideoEditorState> emit) {
    final updatedClips = List<VideoClip>.from(state.videoClips);
    updatedClips[event.index] = updatedClips[event.index].copyWith(duration: event.duration);
    emit(state.copyWith(videoClips: updatedClips));
  }

  void _onUpdateAudioStartTime(UpdateAudioStartTimeEvent event, Emitter<VideoEditorState> emit) {
    final updatedAudioFiles = List<AudioItem>.from(state.audioFiles);
    updatedAudioFiles[event.index] = updatedAudioFiles[event.index].copyWith(startTime: event.startTime);
    emit(state.copyWith(audioFiles: updatedAudioFiles));
  }

  void _onUpdateOverlayStartTime(UpdateOverlayStartTimeEvent event, Emitter<VideoEditorState> emit) {
    final updatedOverlays = List<OverlayItem>.from(state.overlays);
    updatedOverlays[event.index] = updatedOverlays[event.index].copyWith(startTime: event.startTime);
    emit(state.copyWith(overlays: updatedOverlays));
  }

  void _onUpdateTimelinePosition(UpdateTimelinePositionEvent event, Emitter<VideoEditorState> emit) {
    final positionInSeconds = event.position / 20; // 20 pixels = 1 second
    if (state.videoController != null) {
      state.videoController!.seekTo(Duration(seconds: positionInSeconds.round()));
    }
    emit(state.copyWith(timelinePosition: event.position));
  }

  void _onTogglePlayPause(TogglePlayPauseEvent event, Emitter<VideoEditorState> emit) {
    if (state.videoController == null) return;
    if (state.isPlaying) {
      state.videoController!.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      state.videoController!.play();
      emit(state.copyWith(isPlaying: true));
    }
  }

  void _onSeekVideo(SeekVideoEvent event, Emitter<VideoEditorState> emit) {
    if (state.videoController == null) return;
    state.videoController!.seekTo(event.position);
    final positionInPixels = event.position.inSeconds * 20.0;
    emit(state.copyWith(timelinePosition: positionInPixels));
  }

  void _onChangeFilter(ChangeFilterEvent event, Emitter<VideoEditorState> emit) {
    emit(state.copyWith(selectedFilter: event.filter));
  }

  void _onChangeTransition(ChangeTransitionEvent event, Emitter<VideoEditorState> emit) {
    emit(state.copyWith(selectedTransition: event.transition));
  }
}

class VideoClip {
  final VideoPlayerController controller;
  final double startTime;
  final double duration;

  VideoClip({
    required this.controller,
    required this.startTime,
    required this.duration,
  });

  VideoClip copyWith({VideoPlayerController? controller, double? startTime, double? duration}) {
    return VideoClip(
      controller: controller ?? this.controller,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }
}

class AudioItem {
  final File file;
  final double startTime;
  final double duration;

  AudioItem({
    required this.file,
    required this.startTime,
    required this.duration,
  });

  AudioItem copyWith({File? file, double? startTime, double? duration}) {
    return AudioItem(
      file: file ?? this.file,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }
}

class OverlayItem {
   String type;
   String content;
   Offset position;
   double startTime;
   double duration;
   double scale;
   double previewWidth;
   double previewHeight;
   double fontSize;
   Color color;
   bool hasBorder;
   FontStyle fontStyle;

  OverlayItem({
    required this.type,
    required this.content,
    required this.position,
    required this.startTime,
    required this.duration,
    this.scale = 1.0,
    this.previewWidth = 720,
    this.previewHeight = 1280,
    this.fontSize = 24,
    this.color = Colors.white,
    this.hasBorder = false,
    this.fontStyle = FontStyle.normal,
  });

  OverlayItem copyWith({
    String? type,
    String? content,
    Offset? position,
    double? startTime,
    double? duration,
    double? scale,
    double? previewWidth,
    double? previewHeight,
    double? fontSize,
    Color? color,
    bool? hasBorder,
    FontStyle? fontStyle,
  }) {
    return OverlayItem(
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      scale: scale ?? this.scale,
      previewWidth: previewWidth ?? this.previewWidth,
      previewHeight: previewHeight ?? this.previewHeight,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      hasBorder: hasBorder ?? this.hasBorder,
      fontStyle: fontStyle ?? this.fontStyle,
    );
  }
}