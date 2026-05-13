# subtitle_widget

Flutter widgets for displaying subtitles over video content, powered by the [`subtitle`](https://pub.dev/packages/subtitle) package.

Works with **any** video player — just supply a `Stream<Duration>` of the current playback position. A built-in connector for the official `video_player` package is included.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  subtitle_widget: ^0.1.0
```

Then run:

```sh
flutter pub get
```

---

## Quick start

```dart
import 'package:subtitle/subtitle.dart';
import 'package:subtitle_widget/subtitle_widget.dart';

// 1. Create and initialize a SubtitleController (from the subtitle package).
final controller = SubtitleController(
  provider: SubtitleProvider.fromNetwork(
    Uri.parse('https://example.com/captions.srt'),
  ),
);
await controller.initial();

// 2. Provide a Stream<Duration> from your video player.
//    Using video_player:
final Stream<Duration> positionStream =
    VideoPlayerSubtitleConnector.fromVideoPlayer(videoPlayerController);

// 3. Drop SubtitleView into your widget tree (usually inside a Stack).
Stack(
  children: [
    VideoPlayer(videoPlayerController),
    SubtitleView(
      controller: controller,
      position: positionStream,
    ),
  ],
)
```

---

## `SubtitleView` API

| Parameter    | Type                  | Required | Default              | Description                                                                 |
|--------------|-----------------------|----------|----------------------|-----------------------------------------------------------------------------|
| `controller` | `SubtitleController`  | yes      | —                    | A fully initialized controller from the `subtitle` package.                 |
| `position`   | `Stream<Duration>`    | yes      | —                    | Stream that emits the current playback position.                             |
| `style`      | `SubtitleStyle`       | no       | `SubtitleStyle()`    | Visual configuration (colors, font, alignment, …).                          |
| `multiLine`  | `bool`                | no       | `false`              | When `true`, all cues active at the current position are shown (joined with `\n`). |

When no subtitle is active the widget renders an invisible `SizedBox` so it does not consume layout space.

---

## `SubtitleStyle` API

| Property          | Type            | Default                                      | Description                                      |
|-------------------|-----------------|----------------------------------------------|--------------------------------------------------|
| `textStyle`       | `TextStyle`     | white, 16 px, subtle drop shadow             | Style applied to the subtitle text.              |
| `backgroundColor` | `Color?`        | `Colors.black54`                             | Background color of the subtitle bubble.         |
| `padding`         | `EdgeInsets`    | `EdgeInsets.symmetric(horizontal:12, vertical:6)` | Inner padding of the bubble.                |
| `borderRadius`    | `BorderRadius`  | `BorderRadius.circular(4)`                   | Corner radius of the bubble.                     |
| `alignment`       | `Alignment`     | `Alignment.bottomCenter`                     | Where the bubble is anchored in the parent.      |
| `margin`          | `EdgeInsets`    | `EdgeInsets.only(bottom: 24)`                | Outer spacing from the aligned edge.             |

`SubtitleStyle` is immutable and supports `copyWith`.

```dart
SubtitleView(
  controller: controller,
  position: positionStream,
  style: SubtitleStyle(
    textStyle: const TextStyle(color: Colors.yellow, fontSize: 18),
    backgroundColor: Colors.black87,
    alignment: Alignment.topCenter,
    margin: const EdgeInsets.only(top: 16),
  ),
)
```

---

## `VideoPlayerSubtitleConnector`

Converts a `VideoPlayerController` (from the official [`video_player`](https://pub.dev/packages/video_player) package) into a `Stream<Duration>`.

> **Note:** The `video_player` dependency is only required if you use `VideoPlayerSubtitleConnector`. If you use a different video player you can ignore it entirely.

```dart
import 'package:video_player/video_player.dart';
import 'package:subtitle_widget/subtitle_widget.dart';

final videoController = VideoPlayerController.networkUrl(
  Uri.parse('https://example.com/video.mp4'),
);
await videoController.initialize();

final positionStream =
    VideoPlayerSubtitleConnector.fromVideoPlayer(videoController);
```

---

## Custom video player integration

As long as your player exposes a way to observe the current position, you can create a `Stream<Duration>` manually:

```dart
// Example using a ValueNotifier<Duration>:
Stream<Duration> positionStream(ValueNotifier<Duration> notifier) {
  final controller = StreamController<Duration>.broadcast();
  notifier.addListener(() => controller.add(notifier.value));
  return controller.stream;
}

// Example using a periodic timer (polling approach):
Stream<Duration> pollPosition(VideoController vc) {
  return Stream.periodic(
    const Duration(milliseconds: 200),
    (_) => vc.position,
  );
}
```

Pass the resulting stream directly to `SubtitleView.position`.

---

## License

MIT
