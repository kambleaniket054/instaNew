import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instanew/videoeditorDoc/video_editor_bloc.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

import 'EdittorEvents.dart';
import 'EdittorState.dart';
import 'Edittor_Bloc.dart';
// import 'editor_bloc.dart'; // Custom bloc for editor logic

class CreateVideoScreen extends StatelessWidget {
  const CreateVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditorBloc()..add(LoadVideoEvent()),
      child: const VideoEditorView(),
    );
  }
}

class VideoEditorView extends StatelessWidget {
  const VideoEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Video Editor'),
        actions: const [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: BlocBuilder<EditorBloc, EditorState>(
                builder: (context, state) {
                  if (state is EditorLoaded) {
                    return Column(
                      children: [
                        AspectRatio(
                          aspectRatio: state.controller.value.aspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                VideoPlayer(state.controller),
                                ...state.visibleOverlays.map(
                                      (item)
                                  {
                                    final overlaySize = 100.0;
                                    final left = (item.pos_dx * state.controller.value.size.width).clamp(0.0, state.controller.value.size.width - overlaySize);
                                    final top = (item.pos_dy * state.controller.value.size.height).clamp(0.0, state.controller.value.size.height - overlaySize);
                                    return Positioned(
                                      left: left,
                                      top: top,
                                      child: GestureDetector(
                                        onPanUpdate: (dragdetail) {
                                          final newX =(item.pos_dx + dragdetail.delta.dx /  state.controller.value.size.width).clamp(0.0, 1.0);
                                          final newY = (item.pos_dy + dragdetail.delta.dy / state.controller.value.size.height).clamp(0.0, 1.0);
                                          // double asp_width = state
                                          //     .controller.value.size.width;
                                          // double asp_height = state
                                          //     .controller.value.size.height;
                                          // double dx =
                                          //     dragdetail.localPosition.dx;
                                          // double dy =
                                          //     dragdetail.localPosition.dy;
                                          context.read<EditorBloc>().add(
                                              OverlayDragTrackEvent(
                                                  item.id, newX, newY));
                                        },
                                        // feedback: Text(item.content,
                                        //     style: const TextStyle(
                                        //         color: Colors.white,
                                        //         fontSize: 24)),
                                        child: Text(item.content,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24)),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Text(
                            "${state.controller.value.position.inSeconds} / ${state.controller.value.duration.inSeconds}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<EditorBloc, EditorState>(
              builder: (context, state) {
                if (state is EditorLoaded) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(state.controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: () => context.read<EditorBloc>().add(TogglePlayPauseEvent()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.text_fields),
                        onPressed: () => context.read<EditorBloc>().add(AddOverlayEvent(type: 'text', content: 'Text')),
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions),
                        onPressed: () => context.read<EditorBloc>().add(AddOverlayEvent(type: 'sticker', content: '🙂')),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context.read<EditorBloc>().add(DeleteSelectedOverlayEvent()),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 12),
            BlocBuilder<EditorBloc, EditorState>(
              builder: (context, state) {
                if (state is EditorLoaded) {
                  final width = MediaQuery.of(context).size.width;
                  return Stack(
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(4),
                        child: Stack(
                          children: state.tracks.map((item) {
                            int index = state.tracks.indexOf(item);
                            final left = item.start * width;
                            final top_height = (index * 40)+10;
                            final itemWidth = (item.end - item.start) * width;
                            return Positioned(
                              left: left,
                              top: double.tryParse(top_height.toString()),
                              width: itemWidth,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => context.read<EditorBloc>().add(SelectTrackEvent(item.id)),
                                onHorizontalDragUpdate: (details) => context.read<EditorBloc>().add(DragTrackEvent(item.id, details.primaryDelta! / width)),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: item.type == 'text'
                                            ? Colors.green.withOpacity(0.5)
                                            : item.type == 'sticker'
                                            ? Colors.orange.withOpacity(0.5)
                                            : Colors.grey.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(item.content, style: const TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) => context.read<EditorBloc>().add(CropStartTrackEvent(item.id, details.primaryDelta! / width)),
                                        child: Container(width: 10, color: Colors.white.withOpacity(0.3)),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) => context.read<EditorBloc>().add(CropEndTrackEvent(item.id, details.primaryDelta! / width)),
                                        child: Container(width: 10, color: Colors.white.withOpacity(0.3)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Positioned(
                        left: width * state.videoPosition,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
