import 'package:flutter/material.dart';

abstract class VideoEditorEvent {}

class AddVideoEvent extends VideoEditorEvent {}
class AddAudioEvent extends VideoEditorEvent {}
class AddTextOverlayEvent extends VideoEditorEvent {}
class AddStickerEvent extends VideoEditorEvent {
  final String stickerPath;
  final bool fromKeyboard;
  AddStickerEvent(this.stickerPath, {this.fromKeyboard = false});
}
class TogglePlayPauseEvent extends VideoEditorEvent {}
class SeekVideoEvent extends VideoEditorEvent {
  final Duration position;
  SeekVideoEvent(this.position);
}
class UpdateTimelinePositionEvent extends VideoEditorEvent {
  final double position;
  UpdateTimelinePositionEvent(this.position);
}
class UpdateOverlayPositionEvent extends VideoEditorEvent {
  final int overlayIndex;
  final Offset position;
  UpdateOverlayPositionEvent(this.overlayIndex, this.position);
}
class UpdateOverlayStartTimeEvent extends VideoEditorEvent {
  final int overlayIndex;
  final double startTime;
  UpdateOverlayStartTimeEvent(this.overlayIndex, this.startTime);
}
class UpdateOverlayDurationEvent extends VideoEditorEvent {
  final int overlayIndex;
  final double duration;
  UpdateOverlayDurationEvent(this.overlayIndex, this.duration);
}
class UpdateTextOverlayEvent extends VideoEditorEvent {
  final int overlayIndex;
  final String content;
  final double fontSize;
  final Color color;
  final bool hasBorder;
  final FontStyle fontStyle;
  UpdateTextOverlayEvent(this.overlayIndex, this.content, this.fontSize, this.color, this.hasBorder, this.fontStyle);
}
class UpdateVideoStartTimeEvent extends VideoEditorEvent {
  final int videoIndex;
  final double startTime;
  UpdateVideoStartTimeEvent(this.videoIndex, this.startTime);
}
class UpdateVideoDurationEvent extends VideoEditorEvent {
  final int videoIndex;
  final double duration;
  UpdateVideoDurationEvent(this.videoIndex, this.duration);
}
class UpdateAudioStartTimeEvent extends VideoEditorEvent {
  final int audioIndex;
  final double startTime;
  UpdateAudioStartTimeEvent(this.audioIndex, this.startTime);
}
class UpdateAudioDurationEvent extends VideoEditorEvent {
  final int audioIndex;
  final double duration;
  UpdateAudioDurationEvent(this.audioIndex, this.duration);
}
class ChangeFilterEvent extends VideoEditorEvent {
  final String filter;
  ChangeFilterEvent(this.filter);
}
class ChangeTransitionEvent extends VideoEditorEvent {
  final String transition;
  ChangeTransitionEvent(this.transition);
}