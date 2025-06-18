import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

abstract class EditorState extends Equatable {
  const EditorState();

  @override
  List<Object?> get props => [];
}

class EditorInitial extends EditorState {}

class EditorLoading extends EditorState {}

class EditorLoaded extends EditorState {
  final VideoPlayerController controller;
  final List<EditorTrack> tracks;
  final List<OverlayItem> overlays;
  final bool isPlaying;
  final double videoPosition;
  final String? selectedTrackId;

  const EditorLoaded({
    required this.controller,
    required this.tracks,
    required this.overlays,
    required this.isPlaying,
    required this.videoPosition,
    this.selectedTrackId,
  });

  EditorLoaded copyWith({
    VideoPlayerController? controller,
    List<EditorTrack>? tracks,
    List<OverlayItem>? overlays,
    bool? isPlaying,
    double? videoPosition,
    String? selectedTrackId,
  }) {
    return EditorLoaded(
      controller: controller ?? this.controller,
      tracks: tracks ?? this.tracks,
      overlays: overlays ?? this.overlays,
      isPlaying: isPlaying ?? this.isPlaying,
      videoPosition: videoPosition ?? this.videoPosition,
      selectedTrackId: selectedTrackId ?? this.selectedTrackId,
    );
  }

  @override
  List<Object?> get props => [
    controller,
    tracks,
    overlays,
    isPlaying,
    videoPosition,
    selectedTrackId,
  ];
}

class EditorError extends EditorState {
  final String error;
  const EditorError(this.error);

  @override
  List<Object?> get props => [error];
}

class EditorTrack extends Equatable {
  final String id;
  final String type;
  final String content;
  final double start;
  final double end;

  const EditorTrack({
    required this.id,
    required this.type,
    required this.content,
    required this.start,
    required this.end,
  });

  EditorTrack copyWith({
    String? id,
    String? type,
    String? content,
    double? start,
    double? end,
  }) =>
      EditorTrack(
        id: id ?? this.id,
        type: type ?? this.type,
        content: content ?? this.content,
        start: start ?? this.start,
        end: end ?? this.end,
      );

  @override
  List<Object> get props => [id, type, content, start, end];
}

class OverlayItem extends Equatable {
  final String id;
  final String type;
  final String content;
  final double posDx;
  final double posDy;

  const OverlayItem({
    required this.id,
    required this.type,
    required this.content,
    required this.posDx,
    required this.posDy,
  });

  OverlayItem copyWith({
    String? id,
    String? type,
    String? content,
    double? posDx,
    double? posDy,
  }) =>
      OverlayItem(
        id: id ?? this.id,
        type: type ?? this.type,
        content: content ?? this.content,
        posDx: posDx ?? this.posDx,
        posDy: posDy ?? this.posDy,
      );

  @override
  List<Object> get props => [id, type, content, posDx, posDy];
}