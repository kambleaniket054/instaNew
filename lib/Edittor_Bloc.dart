import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

import 'EdittorEvents.dart';
import 'EdittorState.dart';


class TrackItem {
  final String id;
  final String content;
  final String type;
  double pos_dx = 0;
  double pos_dy = 0;
  double start;
  double end;

  TrackItem({
    required this.id,
    required this.content,
    required this.type,
     this.pos_dx = 0,
     this.pos_dy = 0,
    required this.start,
    required this.end,
  });
  TrackItem copyWith({
    double? start,
    double? end,
    double? pos_dx,
    double? pos_dy,
  }) {
    return TrackItem(
      id: id,
      type: type,
      content: content,
      start: start ?? this.start,
      end: end ?? this.end,
      pos_dx: pos_dx ?? this.pos_dx,
      pos_dy: pos_dy ?? this.pos_dy,
    );
  }

}

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  VideoPlayerController? _controller;
  Timer? _positionUpdater;
  String selectedId = '';

  EditorBloc() : super(EditorInitial()) {
    on<LoadVideoEvent>(_onLoadVideo);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<AddOverlayEvent>(_onAddOverlay);
    on<DeleteSelectedOverlayEvent>(_onDeleteOverlay);
    on<SelectTrackEvent>(_onSelectTrack);
    on<DragTrackEvent>(_onDragTrack);
    on<OverlayDragTrackEvent>(_onOverlayDragTrack);
    on<CropStartTrackEvent>(_onCropStart);
    on<CropEndTrackEvent>(_onCropEnd);
    on<UpdatePositionEvent>(_onUpdatePosition);
  }

  Future<void> _onLoadVideo(LoadVideoEvent event, Emitter<EditorState> emit) async {
    _controller = VideoPlayerController.asset("assets/demo.mp4");
    await _controller!.initialize();
    _controller!.addListener(() => add(UpdatePositionEvent()));

    _positionUpdater?.cancel();
    _positionUpdater = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_controller != null && _controller!.value.isInitialized) {
        add(UpdatePositionEvent());
      }
    });

    emit(EditorLoaded(
      controller: _controller!,
      tracks: [],
      visibleOverlays: [],
      videoPosition: 0.0, selectedTrackId: '',
    ));
  }

  void _onTogglePlayPause(TogglePlayPauseEvent event, Emitter<EditorState> emit) {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    add(UpdatePositionEvent());
  }

  void _onAddOverlay(AddOverlayEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final id = UniqueKey().toString();
    final start = s.videoPosition;
    final end = start + 0.1;
    final track = TrackItem(id: id, content: event.content, type: event.type, start: start, end: end);
    emit(s.copyWith(
      tracks: [...s.tracks, track],
      visibleOverlays: [...s.visibleOverlays, track],
    ));
  }

  void _onDeleteOverlay(DeleteSelectedOverlayEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    emit(s.copyWith(
      tracks: s.tracks.where((t) => t.id != selectedId).toList(),
      visibleOverlays: s.visibleOverlays.where((t) => t.id != selectedId).toList(),
    ));
  }

  void _onSelectTrack(SelectTrackEvent event, Emitter<EditorState> emit) {
    selectedId = event.id;
  }

  void _onDragTrack(DragTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedTracks = s.tracks.map((track) {
      if (track.id == event.id) {
        final delta = event.delta;
        final newStart = (track.start + delta).clamp(0.0, 1.0 - (track.end - track.start));
        final newEnd = newStart + (track.end - track.start);
        return TrackItem(id: track.id, content: track.content, type: track.type, start: newStart, end: newEnd);
      }
      return track;
    }).toList();
    emit(s.copyWith(tracks: updatedTracks));
  }

  void _onOverlayDragTrack(OverlayDragTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedTracks = s.tracks.map((track) {
      if (track.id == event.id) {
        final dx = event.dx;
        final dy = event.dy;
        // final newStart = (track.start + delta).clamp(0.0, 1.0 - (track.end - track.start));
        // final newEnd = newStart + (track.end - track.start);
        return track.copyWith(pos_dx: dx,pos_dy: dy);
        return TrackItem(id: track.id, content: track.content, type: track.type, start: track.start, end: track.end,pos_dx: dx,pos_dy: dy);
      }
      return track;
    }).toList();
    emit(s.copyWith(tracks: updatedTracks));
  }

  void _onCropStart(CropStartTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedTracks = s.tracks.map((track) {
      if (track.id == event.id) {
        final newStart = (track.start + event.delta).clamp(0.0, track.end - 0.05);
        return TrackItem(id: track.id, content: track.content, type: track.type, start: newStart, end: track.end);
      }
      return track;
    }).toList();
    emit(s.copyWith(tracks: updatedTracks));
  }

  void _onCropEnd(CropEndTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedTracks = s.tracks.map((track) {
      if (track.id == event.id) {
        final newEnd = (track.end + event.delta).clamp(track.start + 0.05, 1.0);
        return TrackItem(id: track.id, content: track.content, type: track.type, start: track.start, end: newEnd);
      }
      return track;
    }).toList();
    emit(s.copyWith(tracks: updatedTracks));
  }

  void _onUpdatePosition(UpdatePositionEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded || _controller == null) return;
    final s = state as EditorLoaded;
    final duration = _controller!.value.duration.inMilliseconds;
    final position = _controller!.value.position.inMilliseconds;
    final progress = duration > 0 ? position / duration : 0.0;
    emit(s.copyWith(videoPosition: progress));
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    _positionUpdater?.cancel();
    return super.close();
  }
}
