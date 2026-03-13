import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTest extends StatelessWidget {
  VideoPlayerController? controller;

  VideoTest() {
    controller = VideoPlayerController.networkUrl(
        Uri.parse("rtmp://localhost:1935/live/app"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          color: Colors.amber,
          alignment: Alignment.center,
          child: VideoPlayer(controller!),
        ),
      ),
    );
  }
}
