import 'dart:async';

import 'package:video_player/video_player.dart';

class VideoPlayerSubtitleConnector {
  VideoPlayerSubtitleConnector._();

  static Stream<Duration> fromVideoPlayer(VideoPlayerController controller) {
    late StreamController<Duration> streamController;

    void listener() {
      streamController.add(controller.value.position);
    }

    streamController = StreamController<Duration>.broadcast(
      onListen: () => controller.addListener(listener),
      onCancel: () => controller.removeListener(listener),
    );

    return streamController.stream;
  }
}
