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
  // A freely available Creative Commons test video with known duration.
  static const _videoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  // SRT subtitles timed to the first 30 seconds of Big Buck Bunny.
  static const _srtData = '''
1
00:00:03,000 --> 00:00:07,000
Big Buck Bunny

2
00:00:08,000 --> 00:00:13,000
A short film by the Blender Foundation.

3
00:00:14,000 --> 00:00:20,000
A peaceful meadow, a gentle giant,
and some mischievous rodents.

4
00:00:21,000 --> 00:00:27,000
What could possibly go wrong?

5
00:00:28,000 --> 00:00:34,000
Everything.
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
