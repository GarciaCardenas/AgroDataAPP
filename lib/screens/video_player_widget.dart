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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Asegúrate de que la primera frame esté disponible y luego intenta reproducir
      setState(() {});
      _controller.play().catchError((error) {
        print("Error playing video: $error");
        // Puedes mostrar un mensaje al usuario si la reproducción automática falla
      });
    }).catchError((error) {
      print("Error initializing video player: $error");
      // Aquí podrías actualizar el estado del widget para mostrar un mensaje de error más específico
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_controller.value.isInitialized) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
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