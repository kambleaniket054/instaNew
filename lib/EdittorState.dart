import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';
import 'Edittor_Bloc.dart';
import 'models/track_item.dart';

/// Base State
abstract class EditorState extends Equatable {
  const EditorState();

  @override
  List<Object?> get props => [];
}

/// Initial state before anything loads
class EditorInitial extends EditorState {}

/// State while loading video
class EditorLoading extends EditorState {}

/// Loaded state with video and overlays
class EditorLoaded extends EditorState {
  final VideoPlayerController controller;
  final List<TrackItem> tracks; // All media + overlays
  final List<TrackItem> visibleOverlays; // Overlays visible at current time
  final String? selectedTrackId;
  final double videoPosition; // between 0.0 - 1.0

  const EditorLoaded({
    required this.controller,
    required this.tracks,
    required this.visibleOverlays,
    required this.selectedTrackId,
    required this.videoPosition,
  });

  EditorLoaded copyWith({
    VideoPlayerController? controller,
    List<TrackItem>? tracks,
    List<TrackItem>? visibleOverlays,
    String? selectedTrackId,
    double? videoPosition,
  }) {
    return EditorLoaded(
      controller: controller ?? this.controller,
      tracks: tracks ?? this.tracks,
      visibleOverlays: visibleOverlays ?? this.visibleOverlays,
      selectedTrackId: selectedTrackId ?? this.selectedTrackId,
      videoPosition: videoPosition ?? this.videoPosition,
    );
  }

  @override
  List<Object?> get props => [controller, tracks, visibleOverlays, selectedTrackId, videoPosition];
}

/// State on error
class EditorError extends EditorState {
  final String message;

  const EditorError(this.message);

  @override
  List<Object?> get props => [message];
}
