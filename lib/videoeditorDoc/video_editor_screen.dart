import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:instanew/videoeditorDoc/video_editor_state.dart';
import 'package:instanew/videoeditorDoc/video_editor_event.dart';
import 'package:instanew/videoeditorDoc/video_editor_bloc.dart';
import 'package:instanew/videoeditorDoc/text_editor_dialog.dart';
import 'package:instanew/videoeditorDoc/overlay_item.dart';

class VideoEditorScreen extends StatefulWidget {
  @override
  _VideoEditorScreenState createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _seekerAnimationController;
  late ValueNotifier<double> _seekerPosition;
  Map<String, Map<int, File?>> _thumbnailCache = {};
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _seekerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _seekerPosition = ValueNotifier<double>(0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<VideoEditorBloc>();
      bloc.state.videoController?.addListener(() {
        if (bloc.state.videoController == null || !bloc.state.videoController!.value.isInitialized) return;
        final position = bloc.state.videoController!.value.position.inSeconds.toDouble();
        final pixelPosition = position * 20;
        print('Video position: $position seconds, pixel: $pixelPosition');
        _seekerPosition.value = pixelPosition;
        bloc.add(UpdateTimelinePositionEvent(pixelPosition));
        _ensureSeekerVisible(pixelPosition, bloc.state.totalVideoDuration * 20);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _seekerAnimationController.dispose();
    _seekerPosition.dispose();
    super.dispose();
  }

  Future<List<File?>> _preGenerateThumbnails(VideoPlayerController controller, double duration) async {
    const int interval = 5;
    int thumbnailCount = (duration / interval).ceil();
    List<File?> thumbnails = [];
    // Clear cache for this controller to avoid reusing old thumbnails
    _thumbnailCache[controller.dataSource] = {};
    print('Generating $thumbnailCount thumbnails for ${controller.dataSource}');
    for (int i = 0; i < thumbnailCount; i++) {
      final second = i * interval;
      final thumbnail = await _generateThumbnail(controller, second);
      _thumbnailCache[controller.dataSource]![second] = thumbnail;
      thumbnails.add(thumbnail);
      print('Generated thumbnail at $second seconds: ${thumbnail?.path}');
    }
    return thumbnails;
  }

  Future<File?> _generateThumbnail(VideoPlayerController controller, int second) async {
    try {
      // Seek to the desired position to ensure correct frame
      await controller.seekTo(Duration(seconds: second));
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/thumbnail_${controller.dataSource.hashCode}_${second}.jpg';
      final thumbnailFile = await VideoCompress.getFileThumbnail(
        controller.dataSource,
        quality: 25,
        position: second * 1000, // in milliseconds
      );
      if (thumbnailFile != null && thumbnailFile.existsSync()) {
        return thumbnailFile;
      } else {
        print('Thumbnail generation failed for second $second');
        return null;
      }
    } catch (e) {
      print('Error generating thumbnail at second $second: $e');
      return null;
    }
  }

  void _ensureSeekerVisible(double seekerPosition, double timelineWidth) {
    if (!_scrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final scrollOffset = _scrollController.offset;
    final seekerLeftEdge = seekerPosition;
    final seekerRightEdge = seekerPosition + 4;
    const padding = 0.1;
    final minVisible = scrollOffset + (screenWidth * padding);
    final maxVisible = scrollOffset + screenWidth - (screenWidth * padding);

    if (seekerLeftEdge < minVisible) {
      _scrollController.animateTo(
        seekerLeftEdge - (screenWidth * padding),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
      );
    } else if (seekerRightEdge > maxVisible) {
      _scrollController.animateTo(
        seekerRightEdge - screenWidth + (screenWidth * padding),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
      );
    }
  }

  void _updateSeekerFromScroll(VideoEditorState state, double scrollOffset, double timelineWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final visibleCenter = scrollOffset + (screenWidth / 2);
    final newPosition = visibleCenter.clamp(0.0, timelineWidth - 4.0);
    if ((newPosition - _seekerPosition.value).abs() > 20) {
      _animateSeekerTo(newPosition);
      context.read<VideoEditorBloc>().add(UpdateTimelinePositionEvent(newPosition));
    }
  }

  void _animateSeekerTo(double targetPosition) {
    final animation = Tween<double>(begin: _seekerPosition.value, end: targetPosition).animate(
      CurvedAnimation(parent: _seekerAnimationController, curve: Curves.easeOutQuad),
    );
    animation.addListener(() {
      _seekerPosition.value = animation.value;
    });
    _seekerAnimationController.reset();
    _seekerAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final initialVideoPath = ModalRoute.of(context)?.settings.arguments as String?;
    return BlocProvider(
      create: (context) => VideoEditorBloc()
        ..add(initialVideoPath != null ? AddVideoEvent(path: initialVideoPath) : AddVideoEvent()),
      child: BlocBuilder<VideoEditorBloc, VideoEditorState>(
        buildWhen: (previous, current) =>
        previous.videoClips != current.videoClips ||
            previous.audioFiles != current.audioFiles ||
            previous.overlays != current.overlays ||
            previous.totalVideoDuration != current.totalVideoDuration ||
            previous.timelinePosition != current.timelinePosition ||
            previous.isPlaying != current.isPlaying ||
            previous.videoController != current.videoController,
        builder: (context, state) {
          print('BlocBuilder rebuilding, timelinePosition: ${state.timelinePosition}');
          double timelineWidth = state.totalVideoDuration * 20;
          List<Future<List<File?>>> thumbnailFutures = state.videoClips
              .map((clip) => _preGenerateThumbnails(clip.controller, clip.duration))
              .toList();

          return FutureBuilder<List<List<File?>>>(
            future: Future.wait(thumbnailFutures),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: Container(
                    color: Colors.black87,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.redAccent),
                        SizedBox(height: 16),
                        Text('Generating thumbnails...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                print('Thumbnail generation error: ${snapshot.error}');
              }
              return Stack(
                children: [
                  Scaffold(
                    appBar: AppBar(
                      title: Text('Triad Video Editor', style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.grey[900],
                      elevation: 4,
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.black, Colors.grey[800]!],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    if (state.videoController != null && state.videoController!.value.isInitialized)
                                      Center(
                                        child: AspectRatio(
                                          aspectRatio: state.videoController!.value.aspectRatio,
                                          child: VideoPlayer(state.videoController!),
                                        ),
                                      )
                                    else
                                      Center(child: Text('No video selected', style: TextStyle(color: Colors.white))),
                                    ...state.overlays.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final overlay = entry.value;
                                      double currentPosition = state.videoController?.value.position.inSeconds.toDouble() ?? 0;
                                      bool isVisible = currentPosition >= overlay.startTime &&
                                          currentPosition < (overlay.startTime + overlay.duration);
                                      if (!isVisible) return SizedBox.shrink();

                                      final previewWidth = constraints.maxWidth;
                                      final previewHeight = constraints.maxHeight;
                                      final videoAspect = state.videoController?.value.aspectRatio ?? 16 / 9;
                                      final videoHeight = previewWidth / videoAspect;
                                      final scaleX = previewWidth / overlay.previewWidth;
                                      final scaleY = videoHeight / overlay.previewHeight;
                                      final scaledX = overlay.position.dx * scaleX;
                                      final scaledY = overlay.position.dy * scaleY;

                                      return Positioned(
                                        left: scaledX,
                                        top: scaledY,
                                        child: GestureDetector(
                                          onTap: () => overlay.type == 'text'
                                              ? _showTextEditorDialog(context, index, overlay)
                                              : null,
                                          child: Transform.scale(
                                            scale: overlay.scale,
                                            child: Draggable(
                                              feedback: _buildOverlayFeedback(overlay),
                                              onDragUpdate: (details) {
                                                context.read<VideoEditorBloc>().add(
                                                  UpdateOverlayPositionEvent(
                                                    index,
                                                    Offset(
                                                      (details.localPosition.dx / scaleX).clamp(0, overlay.previewWidth),
                                                      (details.localPosition.dy / scaleY).clamp(0, overlay.previewHeight),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: GestureDetector(
                                                onScaleUpdate: (details) {
                                                  context.read<VideoEditorBloc>().add(
                                                    UpdateOverlayScaleEvent(
                                                      index,
                                                      (overlay.scale * details.scale).clamp(0.5, 2.0),
                                                    ),
                                                  );
                                                },
                                                child: _buildOverlayChild(overlay),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification) {
                                _updateSeekerFromScroll(state, notification.metrics.pixels, timelineWidth);
                              }
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: ClampingScrollPhysics(),
                              child: SizedBox(
                                width: timelineWidth > 0 ? timelineWidth : MediaQuery.of(context).size.width,
                                child: CustomMultiChildLayout(
                                  delegate: TimelineLayoutDelegate(state: state, timelineWidth: timelineWidth),
                                  children: [
                                    LayoutId(
                                      id: 'markers',
                                      child: Row(
                                        children: List.generate(
                                          state.totalVideoDuration.ceil() + 1,
                                              (index) => Container(
                                            width: 20,
                                            height: 220,
                                            alignment: Alignment.topCenter,
                                            child: index % 5 == 0
                                                ? Text(
                                              '$index',
                                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                                            )
                                                : Container(width: 1, height: 10, color: Colors.grey[700]),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Video Track
                                    if (state.videoClips.isEmpty)
                                      LayoutId(
                                        id: 'video',
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.grey[800]!, Colors.grey[700]!],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text('No videos added', style: TextStyle(color: Colors.white70)),
                                          ),
                                        ),
                                      )
                                    else
                                      ...state.videoClips.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final clip = entry.value;
                                        final clampedDuration =
                                        clip.duration.clamp(0.0, state.totalVideoDuration - clip.startTime);
                                        print('Rendering video clip $index, start: ${clip.startTime}, duration: $clampedDuration');
                                        return LayoutId(
                                          id: 'video_$index',
                                          child: GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              context.read<VideoEditorBloc>().add(
                                                UpdateVideoStartTimeEvent(
                                                  index,
                                                  (details.localPosition.dx / 20)
                                                      .clamp(0, state.totalVideoDuration - clampedDuration),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: clampedDuration * 20,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[800],
                                                border: Border.all(color: Colors.grey[600]!),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onHorizontalDragUpdate: (details) {
                                                      double newDuration = (clampedDuration * 20 + details.delta.dx) / 20;
                                                      context.read<VideoEditorBloc>().add(
                                                        UpdateVideoDurationEvent(
                                                          index,
                                                          newDuration.clamp(1.0, state.totalVideoDuration - clip.startTime),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 10,
                                                      color: Colors.grey[600],
                                                      child: Icon(Icons.drag_handle, size: 16, color: Colors.white70),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: _buildThumbnails(context, clip.controller, clampedDuration),
                                                  ),
                                                  GestureDetector(
                                                    onHorizontalDragUpdate: (details) {
                                                      double newDuration = (clampedDuration * 20 + details.delta.dx) / 20;
                                                      context.read<VideoEditorBloc>().add(
                                                        UpdateVideoDurationEvent(
                                                          index,
                                                          newDuration.clamp(1.0, state.totalVideoDuration - clip.startTime),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 10,
                                                      color: Colors.grey[600],
                                                      child: const Icon(Icons.drag_handle, size: 16, color: Colors.white70),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    // Audio Track
                                    if (state.audioFiles.isEmpty)
                                      LayoutId(
                                        id: 'audio',
                                        child: Container(
                                          height: 50,
                                          margin: EdgeInsets.only(top: 50),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.purple[800]!, Colors.purple[600]!],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text('No audio added', style: TextStyle(color: Colors.white70)),
                                          ),
                                        ),
                                      )
                                    else
                                      ...state.audioFiles.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final audio = entry.value;
                                        print('Rendering audio $index: ${audio.file.path}');
                                        return LayoutId(
                                          id: 'audio_$index',
                                          child: GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              context.read<VideoEditorBloc>().add(
                                                UpdateAudioStartTimeEvent(
                                                  index,
                                                  (details.localPosition.dx / 20)
                                                      .clamp(0, state.totalVideoDuration - audio.duration),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: audio.duration * 20,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.purple[600],
                                                border: Border.all(color: Colors.purple[400]!),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: CustomPaint(
                                                painter: WaveformPainter(),
                                                child: Center(
                                                  child: Text(
                                                    audio.file.path.split('/').last,
                                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    // Text Track
                                    if (state.overlays.where((overlay) => overlay.type == 'text').isEmpty)
                                      LayoutId(
                                        id: 'text',
                                        child: Container(
                                          height: 50,
                                          margin: EdgeInsets.only(top: 100),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.blue[800]!, Colors.blue[600]!],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text('No text added', style: TextStyle(color: Colors.white70)),
                                          ),
                                        ),
                                      )
                                    else
                                      ...state.overlays
                                          .asMap()
                                          .entries
                                          .where((entry) => entry.value.type == 'text')
                                          .map((entry) {
                                        final index = entry.key;
                                        final overlay = entry.value;
                                        print(
                                            'Rendering text overlay $index: ${overlay.content}, start: ${overlay.startTime}, duration: ${overlay.duration}');
                                        return LayoutId(
                                          id: 'text_$index',
                                          child: GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              context.read<VideoEditorBloc>().add(
                                                UpdateOverlayStartTimeEvent(
                                                  index,
                                                  (details.localPosition.dx / 20)
                                                      .clamp(0, state.totalVideoDuration - overlay.duration),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: overlay.duration * 20,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.blue[600],
                                                border: Border.all(color: Colors.blue[400]!),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onHorizontalDragUpdate: (details) {
                                                      double newDuration = (overlay.duration * 20 + details.delta.dx) / 20;
                                                      context.read<VideoEditorBloc>().add(
                                                        UpdateOverlayDurationEvent(
                                                          index,
                                                          newDuration.clamp(1.0, state.totalVideoDuration - overlay.startTime),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 10,
                                                      color: Colors.blue[400],
                                                      child: Icon(Icons.drag_handle, size: 16, color: Colors.white70),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        overlay.content,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onHorizontalDragUpdate: (details) {
                                                      double newDuration = (overlay.duration * 20 + details.delta.dx) / 20;
                                                      context.read<VideoEditorBloc>().add(
                                                        UpdateOverlayDurationEvent(
                                                          index,
                                                          newDuration.clamp(1.0, state.totalVideoDuration - overlay.startTime),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 10,
                                                      color: Colors.blue[400],
                                                      child: Icon(Icons.drag_handle, size: 16, color: Colors.white70),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    // Sticker Track
                                    if (state.overlays
                                        .where((overlay) =>
                                    overlay.type == 'sticker' ||
                                        overlay.type == 'keyboard_sticker' ||
                                        overlay.type == 'emoji')
                                        .isEmpty)
                                      LayoutId(
                                        id: 'sticker',
                                        child: Container(
                                          height: 50,
                                          margin: EdgeInsets.only(top: 150),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.green[800]!, Colors.green[600]!],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text('No stickers added', style: TextStyle(color: Colors.white70)),
                                          ),
                                        ),
                                      )
                                    else
                                      ...state.overlays
                                          .asMap()
                                          .entries
                                          .where((entry) =>
                                      entry.value.type == 'sticker' ||
                                          entry.value.type == 'keyboard_sticker' ||
                                          entry.value.type == 'emoji')
                                          .map((entry) {
                                        final index = entry.key;
                                        final overlay = entry.value;
                                        print('Rendering sticker $index: ${overlay.content}');
                                        return LayoutId(
                                          id: 'sticker_$index',
                                          child: GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              context.read<VideoEditorBloc>().add(
                                                UpdateOverlayStartTimeEvent(
                                                  index,
                                                  (details.localPosition.dx / 20)
                                                      .clamp(0, state.totalVideoDuration - overlay.duration),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: overlay.duration * 20,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.green[600],
                                                border: Border.all(color: Colors.green[400]!),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: _buildStickerTrack(overlay),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    // Seeker
                                    LayoutId(
                                      id: 'seeker',
                                      child: ValueListenableBuilder<double>(
                                        valueListenable: _seekerPosition,
                                        builder: (context, position, child) {
                                          print('Seeker position: $position');
                                          return GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              final newPosition = (position + details.delta.dx).clamp(0.0, timelineWidth - 4.0);
                                              _animateSeekerTo(newPosition);
                                              context.read<VideoEditorBloc>().add(UpdateTimelinePositionEvent(newPosition));
                                              _ensureSeekerVisible(newPosition, timelineWidth);
                                            },
                                            child: Container(
                                              width: 4,
                                              height: 220,
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius: BorderRadius.circular(2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.withOpacity(0.5),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, -2))],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildButton(context, 'Add Video', () => context.read<VideoEditorBloc>().add(AddVideoEvent())),
                                _buildButton(context, 'Add Audio', () => context.read<VideoEditorBloc>().add(AddAudioEvent())),
                                _buildButton(context, 'Add Text', () => context.read<VideoEditorBloc>().add(AddTextOverlayEvent())),
                                _buildButton(context, 'Add Sticker',
                                        () => context.read<VideoEditorBloc>().add(AddStickerEvent('assets/sticker.png'))),
                                _buildButton(context, 'Add K Sticker',
                                        () => context.read<VideoEditorBloc>().add(AddStickerEvent('assets/k_sticker.png', fromKeyboard: true))),
                                _buildButton(context, 'Add Emoji', () {
                                  setState(() => _showEmojiPicker = !_showEmojiPicker);
                                }),
                                DropdownButton<String>(
                                  value: state.selectedFilter,
                                  items: ['Normal', 'Sepia', 'Grayscale', 'Vintage']
                                      .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
                                      .toList(),
                                  onChanged: (value) => context.read<VideoEditorBloc>().add(ChangeFilterEvent(value!)),
                                  dropdownColor: Colors.grey[800],
                                  style: TextStyle(color: Colors.white),
                                ),
                                DropdownButton<String>(
                                  value: state.selectedTransition,
                                  items: ['Fade', 'Slide', 'Wipe', 'Dissolve']
                                      .map((transition) => DropdownMenuItem(value: transition, child: Text(transition)))
                                      .toList(),
                                  onChanged: (value) => context.read<VideoEditorBloc>().add(ChangeTransitionEvent(value!)),
                                  dropdownColor: Colors.grey[800],
                                  style: TextStyle(color: Colors.white),
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
                                icon: Icon(Icons.replay_10, color: Colors.white70),
                                onPressed: state.videoController != null
                                    ? () => context
                                    .read<VideoEditorBloc>()
                                    .add(SeekVideoEvent(state.videoController!.value.position - Duration(seconds: 10)))
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white70),
                                onPressed: () => context.read<VideoEditorBloc>().add(TogglePlayPauseEvent()),
                              ),
                              IconButton(
                                icon: Icon(Icons.forward_10, color: Colors.white70),
                                onPressed: state.videoController != null
                                    ? () => context
                                    .read<VideoEditorBloc>()
                                    .add(SeekVideoEvent(state.videoController!.value.position + Duration(seconds: 10)))
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    bottomSheet: _showEmojiPicker
                        ? Container(
                      height: 250,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          context.read<VideoEditorBloc>().add(AddEmojiStickerEvent(emoji.emoji));
                          setState(() => _showEmojiPicker = false);
                        },
                        config: Config(
                          height: 250.0, // Matches previous Container height
                          swapCategoryAndBottomBar: false,
                          checkPlatformCompatibility: true,
                          emojiSet: defaultEmojiSet,
                          emojiViewConfig: EmojiViewConfig(
                            columns: 7,
                            emojiSizeMax: 32.0,
                            gridPadding: EdgeInsets.zero,
                            horizontalSpacing: 0,
                            verticalSpacing: 0,
                            recentsLimit: 28,
                            replaceEmojiOnLimitExceed: false,
                            noRecents: Text(
                              'No Recents',
                              style: TextStyle(fontSize: 20, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            buttonMode: ButtonMode.MATERIAL,
                          ),
                          skinToneConfig: SkinToneConfig(
                            enabled: true,
                            dialogBackgroundColor: Colors.grey[900]!,
                            indicatorColor: Colors.grey,
                          ),
                          categoryViewConfig: CategoryViewConfig(
                            backgroundColor: Colors.grey[900]!,
                            indicatorColor: Colors.redAccent,
                            iconColor: Colors.grey,
                            iconColorSelected: Colors.redAccent,
                            dividerColor: Colors.grey[800]!,
                            tabBarHeight: 44,
                            initCategory: Category.RECENT,
                          ),
                          bottomActionBarConfig: BottomActionBarConfig(
                            enabled: true,
                            backgroundColor: Colors.grey[900]!,
                            buttonColor: Colors.grey[900]!,
                            buttonIconColor: Colors.redAccent,
                          ),
                          searchViewConfig: SearchViewConfig(
                            backgroundColor: Colors.grey[900]!,
                            buttonColor: Colors.grey[900]!,
                            buttonIconColor: Colors.redAccent,
                          ),
                        )
                      ),
                    )
                        : null,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverlayChild(OverlayItem overlay) {
    if (overlay.type == 'text') {
      return Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: overlay.hasBorder ? Border.all(color: Colors.white, width: 2) : null,
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          overlay.content,
          style: TextStyle(
            color: overlay.color,
            fontSize: overlay.fontSize,
            fontStyle: overlay.fontStyle,
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
      );
    } else if (overlay.type == 'emoji') {
      return Text(
        overlay.content,
        style: TextStyle(fontSize: 32 * overlay.scale),
      );
    } else {
      return Image.asset(overlay.content, width: 100 * overlay.scale);
    }
  }

  Widget _buildOverlayFeedback(OverlayItem overlay) {
    if (overlay.type == 'text') {
      return Text(
        overlay.content,
        style: TextStyle(
          color: overlay.color,
          fontSize: overlay.fontSize,
          fontStyle: overlay.fontStyle,
        ),
      );
    } else if (overlay.type == 'emoji') {
      return Text(
        overlay.content,
        style: TextStyle(fontSize: 32 * overlay.scale),
      );
    } else {
      return Image.asset(overlay.content, width: 100 * overlay.scale);
    }
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showTextEditorDialog(BuildContext context, int index, OverlayItem overlay) {
    showDialog(
      context: context,
      builder: (context) => TextEditorDialog(
        overlay: overlay,
        onSave: (updatedOverlay) {
          context.read<VideoEditorBloc>().add(UpdateTextOverlayEvent(
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

  Widget _buildThumbnails(BuildContext context, VideoPlayerController controller, double duration) {
    const int interval = 5;
    int thumbnailCount = (duration / interval).ceil();
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      itemCount: thumbnailCount,
      itemBuilder: (context, index) {
        final second = index * interval;
        final cachedThumbnail = _thumbnailCache[controller.dataSource]?[second];
        return Container(
          width: interval * 20,
          height: 50,
          child: cachedThumbnail != null
              ? Image.file(
            cachedThumbnail,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(second),
          )
              : _buildPlaceholder(second),
        );
      },
    );
  }

  Widget _buildPlaceholder(int second) {
    return Container(
      color: Colors.grey[700],
      child: Center(child: Text('$second', style: TextStyle(color: Colors.white70, fontSize: 10))),
    );
  }

  Widget _buildStickerTrack(OverlayItem overlay) {
    final int repeatCount = (overlay.duration / 5).ceil();
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      itemCount: repeatCount,
      itemBuilder: (context, index) {
        return Container(
          width: 50,
          height: 50,
          child: overlay.type == 'emoji'
              ? Text(
            overlay.content,
            style: TextStyle(fontSize: 24),
          )
              : Image.asset(
            overlay.content,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

class TimelineLayoutDelegate extends MultiChildLayoutDelegate {
  final VideoEditorState state;
  final double timelineWidth;

  TimelineLayoutDelegate({required this.state, required this.timelineWidth});

  @override
  void performLayout(Size size) {
    // Markers
    layoutChild('markers', BoxConstraints(maxWidth: timelineWidth, maxHeight: 220));
    positionChild('markers', Offset.zero);

    // Video Track
    if (state.videoClips.isEmpty) {
      layoutChild('video', BoxConstraints(maxWidth: timelineWidth, maxHeight: 50));
      positionChild('video', Offset(0, 0));
    } else {
      for (int i = 0; i < state.videoClips.length; i++) {
        final clip = state.videoClips[i];
        final clampedDuration = clip.duration.clamp(0.0, state.totalVideoDuration - clip.startTime);
        layoutChild('video_$i', BoxConstraints(maxWidth: clampedDuration * 20, maxHeight: 50));
        positionChild('video_$i', Offset(clip.startTime * 20, 0));
      }
    }

    // Audio Track
    if (state.audioFiles.isEmpty) {
      layoutChild('audio', BoxConstraints(maxWidth: timelineWidth, maxHeight: 50));
      positionChild('audio', Offset(0, 50));
    } else {
      for (int i = 0; i < state.audioFiles.length; i++) {
        final audio = state.audioFiles[i];
        layoutChild('audio_$i', BoxConstraints(maxWidth: audio.duration * 20, maxHeight: 50));
        positionChild('audio_$i', Offset(audio.startTime * 20, 50));
      }
    }

    // Text Track
    if (state.overlays.where((overlay) => overlay.type == 'text').isEmpty) {
      layoutChild('text', BoxConstraints(maxWidth: timelineWidth, maxHeight: 50));
      positionChild('text', Offset(0, 100));
    } else {
      for (int i = 0; i < state.overlays.length; i++) {
        if (state.overlays[i].type == 'text') {
          final overlay = state.overlays[i];
          layoutChild('text_$i', BoxConstraints(maxWidth: overlay.duration * 20, maxHeight: 50));
          positionChild('text_$i', Offset(overlay.startTime * 20, 100));
        }
      }
    }

    // Sticker Track
    if (state.overlays
        .where((overlay) => overlay.type == 'sticker' || overlay.type == 'keyboard_sticker' || overlay.type == 'emoji')
        .isEmpty) {
      layoutChild('sticker', BoxConstraints(maxWidth: timelineWidth, maxHeight: 50));
      positionChild('sticker', Offset(0, 150));
    } else {
      for (int i = 0; i < state.overlays.length; i++) {
        if (state.overlays[i].type == 'sticker' ||
            state.overlays[i].type == 'keyboard_sticker' ||
            state.overlays[i].type == 'emoji') {
          final overlay = state.overlays[i];
          layoutChild('sticker_$i', BoxConstraints(maxWidth: overlay.duration * 20, maxHeight: 50));
          positionChild('sticker_$i', Offset(overlay.startTime * 20, 150));
        }
      }
    }

    // Seeker
    print('Layout seeker at: ${state.timelinePosition}');
    layoutChild('seeker', BoxConstraints(maxWidth: 4, maxHeight: 220));
    positionChild('seeker', Offset(state.timelinePosition, 0));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5;
    final double centerY = size.height / 2;
    for (int i = 0; i < size.width; i += 3) {
      final double height = (i % 8 == 0 ? 15 : 8).toDouble();
      canvas.drawLine(
        Offset(i.toDouble(), centerY - height),
        Offset(i.toDouble(), centerY + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}