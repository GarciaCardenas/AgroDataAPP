import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  VideoPlayerWidget({required this.videoFile});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = true; // Variable para rastrear el estado de reproducción

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..addListener(() {
        // Escucha los cambios en el estado de reproducción para actualizar _isPlaying
        if (_controller.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    }).catchError((error) {
      print("Error initializing video player: $error");
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_controller.value.isInitialized) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox( // Envuelve el AspectRatio en un SizedBox
                  height: 500, // Establece la altura deseada
                  width: double.infinity, // Ocupa todo el ancho disponible
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                _ControlsOverlay(
                  isPlaying: _isPlaying,
                  onPlayPause: _togglePlayPause,
                ),
              ],
            );
          } else {
            return Center(child: Text('Error: No se pudo inicializar el reproductor.'));
          }
        } else if (snapshot.hasError) {
          print("FutureBuilder error: ${snapshot.error}");
          return Center(child: Text('Error al cargar el video: ${snapshot.error}'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({
    required this.isPlaying,
    required this.onPlayPause,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black26,
        child: Center(
          child: IconButton(
            key: ValueKey(isPlaying),
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50.0,
            ),
            onPressed: onPlayPause,
          ),
        ),
      ),
    );
  }
}