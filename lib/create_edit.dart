import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'EdittorEvents.dart';
import 'EdittorState.dart';
import 'Edittor_Bloc.dart';


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
      ),
      body: SafeArea(
        child: Column(
          children: [
            BlocSelector<EditorBloc, EditorState, EditorState>(
              selector: (state) => state,
              builder: (context, state) {
                if (state is EditorLoaded) {
                  return AspectRatio(
                    aspectRatio: state.controller.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              VideoPlayer(state.controller),
                              ...state.overlays.map((item) {
                                final left = item.posDx * constraints.maxWidth;
                                final top = item.posDy * constraints.maxHeight;
                                return Positioned(
                                  left: left,
                                  top: top,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      final newX = (item.posDx +
                                          details.delta.dx / constraints.maxWidth)
                                          .clamp(0.0, 1.0);
                                      final newY = (item.posDy +
                                          details.delta.dy / constraints.maxHeight)
                                          .clamp(0.0, 1.0);
                                      context.read<EditorBloc>().add(
                                        OverlayDragEvent(item.id, newX, newY),
                                      );
                                    },
                                    child: Text(
                                      item.content,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 8),
            BlocSelector<EditorBloc, EditorState, EditorState>(
              selector: (state) => state,
              builder: (context, state) {
                if (state is EditorLoaded) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          state.controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () => context
                            .read<EditorBloc>()
                            .add(TogglePlayPauseEvent()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.text_fields),
                        onPressed: () => context.read<EditorBloc>().add(
                          AddOverlayEvent(type: 'text', content: 'Text'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions),
                        onPressed: () => context.read<EditorBloc>().add(
                          AddOverlayEvent(type: 'sticker', content: '🙂'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context
                            .read<EditorBloc>()
                            .add(DeleteOverlayEvent()),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            BlocSelector<EditorBloc, EditorState, EditorState>(
              selector: (state) => state,
              builder: (context, state) {
                if (state is EditorLoaded) {
                  final width = MediaQuery.of(context).size.width;
                  return Stack(
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(4),
                        child: Stack(
                          children: state.tracks.map((item) {
                            final index = state.tracks.indexOf(item);
                            final left = item.start * width;
                            final top = index * 40.0;
                            final itemWidth = (item.end - item.start) * width;
                            return Positioned(
                              left: left,
                              top: top,
                              width: itemWidth,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => context
                                    .read<EditorBloc>()
                                    .add(SelectTrackEvent(item.id)),
                                onHorizontalDragUpdate: (details) => context
                                    .read<EditorBloc>()
                                    .add(DragTrackEvent(
                                    item.id, details.primaryDelta! / width)),
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
                                        child: Text(
                                          item.content,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      height: 40,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) =>
                                            context.read<EditorBloc>().add(
                                              CropStartTrackEvent(
                                                item.id,
                                                details.primaryDelta! / width,
                                              ),
                                            ),
                                        child: Container(
                                          width: 10,
                                          color: Colors.yellow.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      height: 40,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) =>
                                            context.read<EditorBloc>().add(
                                              CropEndTrackEvent(
                                                item.id,
                                                details.primaryDelta! / width,
                                              ),
                                            ),
                                        child: Container(
                                          width: 10,
                                          color: Colors.yellow.withOpacity(0.3),
                                        ),
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
                        left: (width - 24) * state.videoPosition,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}