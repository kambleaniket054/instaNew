// editor_event.dart

import 'package:equatable/equatable.dart';

abstract class EditorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVideoEvent extends EditorEvent {
  LoadVideoEvent();
}

class TogglePlayPauseEvent extends EditorEvent {}

class AddOverlayEvent extends EditorEvent {
  final String type;
  final String content;
  AddOverlayEvent({required this.type, required this.content});

  @override
  List<Object?> get props => [type, content];
}

class DeleteSelectedOverlayEvent extends EditorEvent {}

class SelectTrackEvent extends EditorEvent {
  final String id;
  SelectTrackEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DragTrackEvent extends EditorEvent {
  final String id;
  final double delta;
  DragTrackEvent(this.id, this.delta);

  @override
  List<Object?> get props => [id, delta];
}

class OverlayDragTrackEvent extends EditorEvent {
  final String id;
  final double dx;
  final double dy;
  OverlayDragTrackEvent(this.id, this.dx,this.dy);

  @override
  List<Object?> get props => [id, dx,dy];
}

class CropStartTrackEvent extends EditorEvent {
  final String id;
  final double delta;
  CropStartTrackEvent(this.id, this.delta);

  @override
  List<Object?> get props => [id, delta];
}

class CropEndTrackEvent extends EditorEvent {
  final String id;
  final double delta;
  CropEndTrackEvent(this.id, this.delta);

  @override
  List<Object?> get props => [id, delta];
}

class UpdatePositionEvent extends EditorEvent {}
