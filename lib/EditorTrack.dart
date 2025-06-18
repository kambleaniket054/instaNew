
import 'package:equatable/equatable.dart';

class EditorTrack extends Equatable {
  final String id;
  final String type; // e.g. "video", "text", "emoji"
  final List<EditorMedia> mediaList;

  const EditorTrack({
    required this.id,
    required this.type,
    required this.mediaList,
  });

  EditorTrack copyWith({
    String? id,
    String? type,
    List<EditorMedia>? mediaList,
  }) {
    return EditorTrack(
      id: id ?? this.id,
      type: type ?? this.type,
      mediaList: mediaList ?? this.mediaList,
    );
  }

  @override
  List<Object?> get props => [id, type, mediaList];
}

class EditorMedia extends Equatable {
  final String id;
  final String source; // file path or url
  final Duration start;
  final Duration end;
  final double? overlayX;
  final double? overlayY;

  const EditorMedia({
    required this.id,
    required this.source,
    required this.start,
    required this.end,
    this.overlayX,
    this.overlayY,
  });

  EditorMedia copyWith({
    String? id,
    String? source,
    Duration? start,
    Duration? end,
    double? overlayX,
    double? overlayY,
  }) {
    return EditorMedia(
      id: id ?? this.id,
      source: source ?? this.source,
      start: start ?? this.start,
      end: end ?? this.end,
      overlayX: overlayX ?? this.overlayX,
      overlayY: overlayY ?? this.overlayY,
    );
  }

  @override
  List<Object?> get props => [id, source, start, end, overlayX, overlayY];
}