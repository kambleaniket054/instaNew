import 'dart:ui';

abstract class VideoEditorEvent {}

class AddVideoEvent extends VideoEditorEvent {
  final String? path;
  AddVideoEvent({this.path});
}

class AddAudioEvent extends VideoEditorEvent {}

class AddTextOverlayEvent extends VideoEditorEvent {

}

class AddStickerEvent extends VideoEditorEvent {
  final String path;
  final bool fromKeyboard;
  AddStickerEvent(this.path, {this.fromKeyboard = false});
}

class UpdateOverlayDurationEvent extends VideoEditorEvent {
  final int index;
  final double duration;

  UpdateOverlayDurationEvent(this.index, this.duration);
}

class AddEmojiStickerEvent extends VideoEditorEvent {
  final String emoji;
  AddEmojiStickerEvent(this.emoji);
}

class UpdateOverlayPositionEvent extends VideoEditorEvent {
  final int index;
  final Offset position;
  UpdateOverlayPositionEvent(this.index, this.position);
}

class UpdateOverlayScaleEvent extends VideoEditorEvent {
  final int index;
  final double scale;
  UpdateOverlayScaleEvent(this.index, this.scale);
}

class UpdateTextOverlayEvent extends VideoEditorEvent {
  final int index;
  final String content;
  final double fontSize;
  final Color color;
  final bool hasBorder;
  final FontStyle fontStyle;
  UpdateTextOverlayEvent(this.index, this.content, this.fontSize, this.color, this.hasBorder, this.fontStyle);
}

class UpdateVideoStartTimeEvent extends VideoEditorEvent {
  final int index;
  final double startTime;
  UpdateVideoStartTimeEvent(this.index, this.startTime);
}

class UpdateVideoDurationEvent extends VideoEditorEvent {
  final int index;
  final double duration;
  UpdateVideoDurationEvent(this.index, this.duration);
}

class UpdateAudioStartTimeEvent extends VideoEditorEvent {
  final int index;
  final double startTime;
  UpdateAudioStartTimeEvent(this.index, this.startTime);
}

class UpdateOverlayStartTimeEvent extends VideoEditorEvent {
  final int index;
  final double startTime;
  UpdateOverlayStartTimeEvent(this.index, this.startTime);
}

class UpdateTimelinePositionEvent extends VideoEditorEvent {
  final double position;
  UpdateTimelinePositionEvent(this.position);
}

class TogglePlayPauseEvent extends VideoEditorEvent {}

class SeekVideoEvent extends VideoEditorEvent {
  final Duration position;
  SeekVideoEvent(this.position);
}

class ChangeFilterEvent extends VideoEditorEvent {
  final String filter;
  ChangeFilterEvent(this.filter);
}

class ChangeTransitionEvent extends VideoEditorEvent {
  final String transition;
  ChangeTransitionEvent(this.transition);
}