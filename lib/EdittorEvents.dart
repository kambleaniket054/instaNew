import 'package:equatable/equatable.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoEvent extends EditorEvent {}

class TogglePlayPauseEvent extends EditorEvent {}

class SelectTrackEvent extends EditorEvent {
  final String trackId;
  const SelectTrackEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class DragTrackEvent extends EditorEvent {
  final String trackId;
  final double delta;
  const DragTrackEvent(this.trackId, this.delta);

  @override
  List<Object?> get props => [trackId, delta];
}

class CropStartTrackEvent extends EditorEvent {
  final String trackId;
  final double delta;
  const CropStartTrackEvent(this.trackId, this.delta);

  @override
  List<Object?> get props => [trackId, delta];
}

class CropEndTrackEvent extends EditorEvent {
  final String trackId;
  final double delta;
  const CropEndTrackEvent(this.trackId, this.delta);

  @override
  List<Object?> get props => [trackId, delta];
}

class OverlayDragEvent extends EditorEvent {
  final String overlayId;
  final double dx;
  final double dy;
  const OverlayDragEvent(this.overlayId, this.dx, this.dy);

  @override
  List<Object?> get props => [overlayId, dx, dy];
}

class AddOverlayEvent extends EditorEvent {
  final String type;
  final String content;
  const AddOverlayEvent({required this.type, required this.content});

  @override
  List<Object?> get props => [type, content];
}

class DeleteOverlayEvent extends EditorEvent {}

class UpdateFrameEvent extends EditorEvent {}