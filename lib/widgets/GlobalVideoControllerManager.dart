import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class GlobalVideoControllerManager {
  static ValueNotifier<CachedVideoPlayerController?> activeVideoController = ValueNotifier(null);

  static void pauseActiveVideo() {
    if (activeVideoController.value != null && activeVideoController.value!.value.isPlaying) {
      activeVideoController.value!.pause();
    }
  }

  static void setActiveVideoController(CachedVideoPlayerController? newController) {
    pauseActiveVideo();
    activeVideoController.value = newController;
  }
}
