// import 'dart:io';
// import 'dart:ui';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:video_player/video_player.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:audioplayers/audioplayers.dart';
// import '../../model/OverlayItem.dart';
// import '../../model/VideoClip.dart';
// import '../../model/audioItem.dart';
// import 'VideoEditorEvent.dart';
// import 'VideoEditorState.dart';
//
// class VideoEditorBloc extends Bloc<VideoEditorEvent, VideoEditorState> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   VideoEditorBloc() : super(VideoEditorState()) {
//     on<AddVideoEvent>(_onAddVideo);
//     on<AddAudioEvent>(_onAddAudio);
//     on<AddTextOverlayEvent>(_onAddTextOverlay);
//     on<AddStickerEvent>(_onAddSticker);
//     on<TogglePlayPauseEvent>(_onTogglePlayPause);
//     on<SeekVideoEvent>(_onSeekVideo);
//     on<UpdateTimelinePositionEvent>(_onUpdateTimelinePosition);
//     on<UpdateOverlayPositionEvent>(_onUpdateOverlayPosition);
//     on<UpdateOverlayStartTimeEvent>(_onUpdateOverlayStartTime);
//     on<UpdateOverlayDurationEvent>(_onUpdateOverlayDuration);
//     on<UpdateTextOverlayEvent>(_onUpdateTextOverlay);
//     on<UpdateVideoStartTimeEvent>(_onUpdateVideoStartTime);
//     on<UpdateVideoDurationEvent>(_onUpdateVideoDuration);
//     on<UpdateAudioStartTimeEvent>(_onUpdateAudioStartTime);
//     on<UpdateAudioDurationEvent>(_onUpdateAudioDuration);
//     on<ChangeFilterEvent>(_onChangeFilter);
//     on<ChangeTransitionEvent>(_onChangeTransition);
//   }
//
//   Future<void> _onAddVideo(AddVideoEvent event, Emitter<VideoEditorState> emit) async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video,);
//       if (result != null && result.files.single.path != null) {
//         File videoFile = File(result.files.single.path!);
//         final controller = VideoPlayerController.file(videoFile);
//         await controller.initialize();
//         double duration = controller.value.duration.inSeconds.toDouble();
//         final newClip = VideoClip(
//           file: videoFile,
//           controller: controller,
//           startTime: state.totalVideoDuration,
//           duration: duration,
//         );
//         emit(state.copyWith(
//           videoClips: [...state.videoClips, newClip],
//           videoController: state.videoController ?? controller,
//           totalVideoDuration: state.totalVideoDuration + duration,
//         ));
//       }
//     } catch (e) {
//       print('Error adding video: $e');
//     }
//   }
//
//   Future<void> _onAddAudio(AddAudioEvent event, Emitter<VideoEditorState> emit) async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
//       if (result != null && result.files.single.path != null) {
//         File audioFile = File(result.files.single.path!);
//         await _audioPlayer.setSourceDeviceFile(audioFile.path);
//         final newAudio = AudioItem(
//           file: audioFile,
//           startTime: state.timelinePosition,
//           duration: 10.0, // Default duration, adjustable in timeline
//         );
//         emit(state.copyWith(audioFiles: [...state.audioFiles, newAudio]));
//       }
//     } catch (e) {
//       print('Error adding audio: $e');
//     }
//   }
//
//   void _onAddTextOverlay(AddTextOverlayEvent event, Emitter<VideoEditorState> emit) {
//     emit(state.copyWith(
//       overlays: [
//         ...state.overlays,
//         OverlayItem(
//           type: 'text',
//           content: 'New Text',
//           position: Offset(100, 100),
//           startTime: state.timelinePosition,
//           duration: 5.0,
//         ),
//       ],
//     ));
//   }
//
//   void _onAddSticker(AddStickerEvent event, Emitter<VideoEditorState> emit) {
//     emit(state.copyWith(
//       overlays: [
//         ...state.overlays,
//         OverlayItem(
//           type: event.fromKeyboard ? 'keyboard_sticker' : 'sticker',
//           content: event.stickerPath,
//           position: Offset(100, 100),
//           startTime: state.timelinePosition,
//           duration: 5.0,
//         ),
//       ],
//     ));
//   }
//
//   void _onTogglePlayPause(TogglePlayPauseEvent event, Emitter<VideoEditorState> emit) {
//     if (state.isPlaying) {
//       state.videoController?.pause();
//       _audioPlayer.pause();
//     } else {
//       state.videoController?.play();
//       if (state.audioFiles.isNotEmpty) _audioPlayer.resume();
//     }
//     emit(state.copyWith(isPlaying: !state.isPlaying));
//   }
//
//   void _onSeekVideo(SeekVideoEvent event, Emitter<VideoEditorState> emit) {
//     state.videoController?.seekTo(event.position);
//     emit(state.copyWith(timelinePosition: event.position.inSeconds.toDouble()));
//   }
//
//   void _onUpdateTimelinePosition(UpdateTimelinePositionEvent event, Emitter<VideoEditorState> emit) {
//     state.videoController?.seekTo(Duration(seconds: (event.position / 20).round()));
//     emit(state.copyWith(timelinePosition: event.position));
//   }
//
//   void _onUpdateOverlayPosition(UpdateOverlayPositionEvent event, Emitter<VideoEditorState> emit) {
//     final updatedOverlays = List<OverlayItem>.from(state.overlays);
//     updatedOverlays[event.overlayIndex].position = event.position;
//     emit(state.copyWith(overlays: updatedOverlays));
//   }
//
//   void _onUpdateOverlayStartTime(UpdateOverlayStartTimeEvent event, Emitter<VideoEditorState> emit) {
//     final updatedOverlays = List<OverlayItem>.from(state.overlays);
//     updatedOverlays[event.overlayIndex].startTime = event.startTime;
//     emit(state.copyWith(overlays: updatedOverlays));
//   }
//
//   void _onUpdateOverlayDuration(UpdateOverlayDurationEvent event, Emitter<VideoEditorState> emit) {
//     final updatedOverlays = List<OverlayItem>.from(state.overlays);
//     updatedOverlays[event.overlayIndex].duration = event.duration;
//     emit(state.copyWith(overlays: updatedOverlays));
//   }
//
//   void _onUpdateTextOverlay(UpdateTextOverlayEvent event, Emitter<VideoEditorState> emit) {
//     final updatedOverlays = List<OverlayItem>.from(state.overlays);
//     updatedOverlays[event.overlayIndex]
//       ..content = event.content
//       ..fontSize = event.fontSize
//       ..color = event.color
//       ..hasBorder = event.hasBorder
//       ..fontStyle = event.fontStyle;
//     emit(state.copyWith(overlays: updatedOverlays));
//   }
//
//   void _onUpdateVideoStartTime(UpdateVideoStartTimeEvent event, Emitter<VideoEditorState> emit) {
//     final updatedClips = List<VideoClip>.from(state.videoClips);
//     updatedClips[event.videoIndex].startTime = event.startTime;
//     emit(state.copyWith(videoClips: updatedClips));
//   }
//
//   void _onUpdateVideoDuration(UpdateVideoDurationEvent event, Emitter<VideoEditorState> emit) {
//     final updatedClips = List<VideoClip>.from(state.videoClips);
//     updatedClips[event.videoIndex].duration = event.duration;
//     emit(state.copyWith(videoClips: updatedClips));
//   }
//
//   void _onUpdateAudioStartTime(UpdateAudioStartTimeEvent event, Emitter<VideoEditorState> emit) {
//     final updatedAudioFiles = List<AudioItem>.from(state.audioFiles);
//     updatedAudioFiles[event.audioIndex].startTime = event.startTime;
//     emit(state.copyWith(audioFiles: updatedAudioFiles));
//   }
//
//   void _onUpdateAudioDuration(UpdateAudioDurationEvent event, Emitter<VideoEditorState> emit) {
//     final updatedAudioFiles = List<AudioItem>.from(state.audioFiles);
//     updatedAudioFiles[event.audioIndex].duration = event.duration;
//     emit(state.copyWith(audioFiles: updatedAudioFiles));
//   }
//
//   void _onChangeFilter(ChangeFilterEvent event, Emitter<VideoEditorState> emit) {
//     emit(state.copyWith(selectedFilter: event.filter));
//   }
//
//   void _onChangeTransition(ChangeTransitionEvent event, Emitter<VideoEditorState> emit) {
//     emit(state.copyWith(selectedTransition: event.transition));
//   }
//
//   @override
//   Future<void> close() {
//     state.videoController?.dispose();
//     _audioPlayer.dispose();
//     return super.close();
//   }
// }