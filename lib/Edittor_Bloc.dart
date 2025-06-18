import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import 'EdittorEvents.dart';
import 'EdittorState.dart';


class EditorBloc extends Bloc<EditorEvent, EditorState> {
  VideoPlayerController? _controller;
  Timer? _timer;

  EditorBloc() : super(EditorInitial()) {
    on<LoadVideoEvent>(_onLoadVideo);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<SelectTrackEvent>(_onSelectTrack);
    on<DragTrackEvent>(_onDragTrack);
    on<CropStartTrackEvent>(_onCropStartTrack);
    on<CropEndTrackEvent>(_onCropEndTrack);
    on<OverlayDragEvent>(_onOverlayDrag);
    on<AddOverlayEvent>(_onAddOverlay);
    on<DeleteOverlayEvent>(_onDeleteOverlay);
    on<UpdateFrameEvent>(_onUpdateFrame);
  }

  Future<void> _onLoadVideo(LoadVideoEvent event, Emitter<EditorState> emit) async {
    emit(EditorLoading());
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
      );
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();

      final tracks = [
        EditorTrack(
          id: const Uuid().v4(),
          type: 'video',
          content: 'Video',
          start: 0.0,
          end: 1.0,
        ),
      ];

      emit(EditorLoaded(
        controller: _controller!,
        tracks: tracks,
        overlays: [],
        isPlaying: true,
        videoPosition: 0.0,
        selectedTrackId: null,
      ));

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_controller!.value.isInitialized && _controller!.value.isPlaying) {
          add(UpdateFrameEvent());
        }
      });
    } catch (e) {
      emit(EditorError(e.toString()));
    }
  }

  Future<void> _onTogglePlayPause(TogglePlayPauseEvent event, Emitter<EditorState> emit) async {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    s.isPlaying ? await _controller!.pause() : await _controller!.play();
    emit(s.copyWith(isPlaying: _controller!.value.isPlaying));
  }

  void _onSelectTrack(SelectTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    emit(s.copyWith(selectedTrackId: event.trackId));
  }

  void _onDragTrack(DragTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedTracks = s.tracks.map((track) {
      if (track.id == event.trackId) {
        final duration = track.end - track.start;
        final newStart = (track.start + event.delta).clamp(0.0, 1.0 - duration);
        final newEnd = newStart + duration;
        return track.copyWith(start: newStart, end: newEnd);
      }
      return track;
    }).toList();
    emit(s.copyWith(tracks: updatedTracks));
  }

  void _onCropStartTrack(CropStartTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedTracks = s.tracks.map((track) {
      if (track.id == event.trackId) {
        final newStart = (track.start + event.delta).clamp(0.0, track.end - 0.1);
        return track.copyWith(start: newStart);
      }
      return track;
    }).toList();
    emit(s.copyWith(tracks: updatedTracks));
  }

  void _onCropEndTrack(CropEndTrackEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedTracks = s.tracks.map((track) {
      if (track.id == event.trackId) {
        final newEnd = (track.end + event.delta).clamp(track.start + 0.1, 1.0);
        return track.copyWith(end: newEnd);
      }
      return track;
    }).toList();
    emit(s.copyWith(tracks: updatedTracks));
  }

  void _onOverlayDrag(OverlayDragEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedOverlays = s.overlays.map((overlay) {
      if (overlay.id == event.overlayId) {
        return overlay.copyWith(posDx: event.dx, posDy: event.dy);
      }
      return overlay;
    }).toList();
    emit(s.copyWith(overlays: updatedOverlays));
  }

  void _onAddOverlay(AddOverlayEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final overlay = OverlayItem(
      id: const Uuid().v4(),
      type: event.type,
      content: event.content,
      posDx: 0.5,
      posDy: 0.5,
    );
    emit(s.copyWith(overlays: [...s.overlays, overlay]));
  }

  void _onDeleteOverlay(DeleteOverlayEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final updatedOverlays = s.overlays.where((overlay) => overlay.id != s.selectedTrackId).toList();
    emit(s.copyWith(overlays: updatedOverlays, selectedTrackId: null));
  }

  void _onUpdateFrame(UpdateFrameEvent event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final s = state as EditorLoaded;
    final position = _controller!.value.position.inSeconds / _controller!.value.duration.inSeconds;
    emit(s.copyWith(videoPosition: position.clamp(0.0, 1.0)));
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _controller?.dispose();
    await super.close();
  }
}