import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:subtitle_widget/subtitle_widget.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'subtitle_widget Example',
      debugShowCheckedModeBanner: false,
      home: VideoSubtitleScreen(),
    );
  }
}

class VideoSubtitleScreen extends StatefulWidget {
  const VideoSubtitleScreen({super.key});

  @override
  State<VideoSubtitleScreen> createState() => _VideoSubtitleScreenState();
}

class _VideoSubtitleScreenState extends State<VideoSubtitleScreen> {
  static const _videoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  static const _srtData = '''
1
00:00:00,500 --> 00:00:02,500
A butterfly in slow motion.

2
00:00:02,500 --> 00:00:05,000
Watch the wings catch the light.

3
00:00:05,000 --> 00:00:07,500
subtitle_widget demo — powered by the subtitle package.
''';

  late VideoPlayerController _videoController;
  late SubtitleController _subtitleController;
  bool _videoReady = false;
  bool _subtitlesReady = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrl),
    )..initialize().then((_) {
        setState(() => _videoReady = true);
        _videoController.setLooping(false);
      });

    _subtitleController = SubtitleController(
      provider: SubtitleProvider.fromString(
        data: _srtData,
        type: SubtitleType.srt,
      ),
    );
    _subtitleController.initial().then((_) {
      setState(() => _subtitlesReady = true);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = _videoReady && _subtitlesReady;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('subtitle_widget demo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ready ? _buildPlayer() : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildPlayer() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
              SubtitleView(
                controller: _subtitleController,
                position: VideoPlayerSubtitleConnector.fromVideoPlayer(
                  _videoController,
                ),
                multiLine: true,
                style: SubtitleStyle(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black),
                    ],
                  ),
                  backgroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 32),
                ),
              ),
            ],
          ),
        ),
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _videoController.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _togglePlayPause,
          ),
          Expanded(
            child: VideoProgressIndicator(
              _videoController,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white38,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder(
            valueListenable: _videoController,
            builder: (_, value, __) {
              final pos = value.position;
              final dur = value.duration;
              return Text(
                '${_fmt(pos)} / ${_fmt(dur)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
