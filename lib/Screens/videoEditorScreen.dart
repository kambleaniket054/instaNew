import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/OverlayItem.dart';
import '../domain/videoEdittingBloc/VideoEditorBloc.dart';
import '../domain/videoEdittingBloc/VideoEditorEvent.dart';
import '../domain/videoEdittingBloc/VideoEditorState.dart';
import '../widgets/TextEditorDialog.dart';


class VideoEditorScreen extends StatelessWidget {
  VideoEditorBloc _videobloc = VideoEditorBloc();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoEditorBloc, VideoEditorState>(
      bloc: _videobloc,
      listener: (context,state){},
      builder: (context, state) {
        double timelineWidth = state.totalVideoDuration * 20;

        return Scaffold(
          appBar: AppBar(
            title: Text('TikTok Video Editor'),
            actions: [
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exporting video... (Not implemented)')),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      if (state.videoController != null && state.videoController!.value.isInitialized)
                        AspectRatio(
                          aspectRatio: state.videoController!.value.aspectRatio,
                          child: VideoPlayer(state.videoController!),
                        )
                      else
                        Center(child: Text('No video selected')),
                      ...state.overlays.asMap().entries.map((entry) {
                        final index = entry.key;
                        final overlay = entry.value;
                        double currentPosition = state.videoController?.value.position.inSeconds.toDouble() ?? 0;
                        bool isVisible = currentPosition >= overlay.startTime &&
                            currentPosition < (overlay.startTime + overlay.duration);

                        return isVisible
                            ? Positioned(
                          left: overlay.position.dx,
                          top: overlay.position.dy,
                          child: GestureDetector(
                            onTap: () => overlay.type == 'text'
                                ? _showTextEditorDialog(context, index, overlay)
                                : null,
                            child: Draggable(
                              child: overlay.type == 'text'
                                  ? Container(
                                decoration: BoxDecoration(
                                  border: overlay.hasBorder
                                      ? Border.all(color: Colors.white)
                                      : null,
                                ),
                                child: Text(
                                  overlay.content,
                                  style: TextStyle(
                                    color: overlay.color,
                                    fontSize: overlay.fontSize,
                                    fontStyle: overlay.fontStyle,
                                  ),
                                ),
                              )
                                  : Image.asset(overlay.content, width: 100),
                              feedback: overlay.type == 'text'
                                  ? Text(overlay.content,
                                  style: TextStyle(
                                    color: overlay.color,
                                    fontSize: overlay.fontSize,
                                    fontStyle: overlay.fontStyle,
                                  ))
                                  : Image.asset(overlay.content, width: 100),
                              onDragEnd: (details) {
                                _videobloc.add(
                                    UpdateOverlayPositionEvent(index, details.offset));
                              },
                            ),
                          ),
                        )
                            : SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
              Container(
                height: 200,
                color: Colors.grey[900],
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: timelineWidth,
                    child: Column(
                      children: [
                        // Video Timeline
                        Container(
                          height: 50,
                          child: Stack(
                            children: state.videoClips.asMap().entries.map((entry) {
                              final index = entry.key;
                              final clip = entry.value;
                              return Positioned(
                                left: clip.startTime * 20,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    _videobloc.add(UpdateVideoStartTimeEvent(
                                        index,
                                        (details.localPosition.dx / 20)
                                            .clamp(0, state.totalVideoDuration - clip.duration)));
                                  },
                                  onHorizontalDragEnd: (details) {},
                                  child: Container(
                                    width: clip.duration * 20,
                                    height: 50,
                                    color: Colors.grey[800],
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (clip.duration * 20 + details.delta.dx) / 20;
                                            _videobloc.add(UpdateVideoDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - clip.startTime)));
                                          },
                                          child: Container(width: 10, color: Colors.grey[600]),
                                        ),
                                        Expanded(child: Center(child: Text('Video $index'))),
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (clip.duration * 20 + details.delta.dx) / 20;
                                            _videobloc.add(UpdateVideoDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - clip.startTime)));
                                          },
                                          child: Container(width: 10, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList()
                              ..add(
                                Positioned(
                                  left: state.timelinePosition,
                                  child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      _videobloc.add(UpdateTimelinePositionEvent(
                                          details.localPosition.dx.clamp(0, timelineWidth - 20)));
                                    },
                                    child: Container(width: 2, height: 50, color: Colors.red),
                                  ),
                                ),
                              ),
                          ),
                        ),
                        // Audio Timeline
                        Container(
                          height: 50,
                          child: Stack(
                            children: state.audioFiles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final audio = entry.value;
                              return Positioned(
                                left: audio.startTime * 20,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    _videobloc.add(UpdateAudioStartTimeEvent(
                                        index,
                                        (details.localPosition.dx / 20)
                                            .clamp(0, state.totalVideoDuration - audio.duration)));
                                  },
                                  child: Container(
                                    width: audio.duration * 20,
                                    height: 50,
                                    color: Colors.purple[800],
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (audio.duration * 20 + details.delta.dx) / 20;
                                            _videobloc.add(UpdateAudioDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - audio.startTime)));
                                          },
                                          child: Container(width: 10, color: Colors.purple[600]),
                                        ),
                                        Expanded(child: Center(child: Text('Audio $index'))),
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (audio.duration * 20 + details.delta.dx) / 20;
                                            _videobloc.add(UpdateAudioDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - audio.startTime)));
                                          },
                                          child: Container(width: 10, color: Colors.purple[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Text Overlay Timeline
                        Container(
                          height: 50,
                          child: Stack(
                            children: state.overlays
                                .asMap()
                                .entries
                                .where((e) => e.value.type == 'text')
                                .map((entry) {
                              final index = entry.key;
                              final overlay = entry.value;
                              return Positioned(
                                left: overlay.startTime * 20,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    _videobloc.add(UpdateOverlayStartTimeEvent(
                                        index,
                                        (details.localPosition.dx / 20)
                                            .clamp(0, state.totalVideoDuration - overlay.duration)));
                                  },
                                  child: Container(
                                    width: overlay.duration * 20,
                                    height: 50,
                                    color: Colors.blue[800],
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (overlay.duration * 20 + details.delta.dx) / 20;
                                            _videobloc.add(UpdateOverlayDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - overlay.startTime)));
                                          },
                                          child: Container(width: 10, color: Colors.blue[600]),
                                        ),
                                        Expanded(child: Center(child: Text('Text'))),
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (overlay.duration * 20 + details.delta.dx) / 20;
                                            _videobloc.add(UpdateOverlayDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - overlay.startTime)));
                                          },
                                          child: Container(width: 10, color: Colors.blue[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Sticker Timeline
                        Container(
                          height: 50,
                          child: Stack(
                            children: state.overlays
                                .asMap()
                                .entries
                                .where((e) => e.value.type.contains('sticker'))
                                .map((entry) {
                              final index = entry.key;
                              final overlay = entry.value;
                              return Positioned(
                                left: overlay.startTime * 20,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                   _videobloc.add(UpdateOverlayStartTimeEvent(
                                        index,
                                        (details.localPosition.dx / 20)
                                            .clamp(0, state.totalVideoDuration - overlay.duration)));
                                  },
                                  child: Container(
                                    width: overlay.duration * 20,
                                    height: 50,
                                    color: overlay.type == 'keyboard_sticker' ? Colors.orange[800] : Colors.green[800],
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (overlay.duration * 20 + details.delta.dx) / 20;
                                           _videobloc.add(UpdateOverlayDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - overlay.startTime)));
                                          },
                                          child: Container(
                                              width: 10,
                                              color: overlay.type == 'keyboard_sticker'
                                                  ? Colors.orange[600]
                                                  : Colors.green[600]),
                                        ),
                                        Expanded(
                                            child: Center(
                                                child: Text(overlay.type == 'keyboard_sticker' ? 'K Sticker' : 'Sticker'))),
                                        GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            double newDuration = (overlay.duration * 20 + details.delta.dx) / 20;
                                           _videobloc.add(UpdateOverlayDurationEvent(
                                                index, newDuration.clamp(1.0, state.totalVideoDuration - overlay.startTime)));
                                          },
                                          child: Container(
                                              width: 10,
                                              color: overlay.type == 'keyboard_sticker'
                                                  ? Colors.orange[600]
                                                  : Colors.green[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildButton(context, 'Add Video', () =>_videobloc.add(AddVideoEvent())),
                      _buildButton(context, 'Add Audio', () =>_videobloc.add(AddAudioEvent())),
                      _buildButton(context, 'Add Text', () =>_videobloc.add(AddTextOverlayEvent())),
                      _buildButton(context, 'Add Sticker',
                              () =>_videobloc.add(AddStickerEvent('assets/sticker.png'))),
                      _buildButton(context, 'Add K Sticker',
                              () =>_videobloc.add(AddStickerEvent('assets/k_sticker.png', fromKeyboard: true))),
                      DropdownButton<String>(
                        value: state.selectedFilter,
                        items: ['Normal', 'Sepia', 'Grayscale', 'Vintage']
                            .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
                            .toList(),
                        onChanged: (value) =>_videobloc.add(ChangeFilterEvent(value!)),
                      ),
                      DropdownButton<String>(
                        value: state.selectedTransition,
                        items: ['Fade', 'Slide', 'Wipe', 'Dissolve']
                            .map((transition) => DropdownMenuItem(value: transition, child: Text(transition)))
                            .toList(),
                        onChanged: (value) =>_videobloc.add(ChangeTransitionEvent(value!)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10),
                      onPressed: state.videoController != null
                          ? () =>_videobloc.add(SeekVideoEvent(
                          state.videoController!.value.position - Duration(seconds: 10)))
                          : null,
                    ),
                    IconButton(
                      icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () =>_videobloc.add(TogglePlayPauseEvent()),
                    ),
                    IconButton(
                      icon: Icon(Icons.forward_10),
                      onPressed: state.videoController != null
                          ? () =>_videobloc.add(SeekVideoEvent(
                          state.videoController!.value.position + Duration(seconds: 10)))
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
    );
  }

  void _showTextEditorDialog(BuildContext context, int index, OverlayItem overlay) {
    showDialog(
      context: context,
      builder: (context) => TextEditorDialog(
        overlay: overlay,
        onSave: (updatedOverlay) {
         _videobloc.add(UpdateTextOverlayEvent(
            index,
            updatedOverlay.content,
            updatedOverlay.fontSize,
            updatedOverlay.color,
            updatedOverlay.hasBorder,
            updatedOverlay.fontStyle,
          ));
        },
      ),
    );
  }
}