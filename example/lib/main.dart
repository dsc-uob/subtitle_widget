import 'dart:async';

import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:subtitle_widget/subtitle_widget.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'subtitle_widget Example',
      home: SubtitleDemoScreen(),
    );
  }
}

class SubtitleDemoScreen extends StatefulWidget {
  const SubtitleDemoScreen({super.key});

  @override
  State<SubtitleDemoScreen> createState() => _SubtitleDemoScreenState();
}

class _SubtitleDemoScreenState extends State<SubtitleDemoScreen> {
  static const _srtData = '''
1
00:00:01,000 --> 00:00:04,000
Welcome to the subtitle_widget demo.

2
00:00:05,000 --> 00:00:09,000
This text appears from 5 to 9 seconds.

3
00:00:10,000 --> 00:00:14,000
And this one from 10 to 14 seconds.
''';

  late SubtitleController _controller;
  late StreamController<Duration> _positionController;
  Duration _position = Duration.zero;
  bool _initialized = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _positionController = StreamController<Duration>.broadcast();
    _controller = SubtitleController(
      provider: SubtitleProvider.fromString(
        data: _srtData,
        type: SubtitleType.srt,
      ),
    );
    _controller.initial().then((_) {
      setState(() => _initialized = true);
    });
  }

  void _startPlayback() {
    _timer?.cancel();
    setState(() => _position = Duration.zero);
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      _position += const Duration(milliseconds: 200);
      _positionController.add(_position);
      if (_position >= const Duration(seconds: 15)) {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionController.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('subtitle_widget Demo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Center(
            child: _initialized
                ? const Text(
                    'Video area\n(playback simulated)',
                    style: TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center,
                  )
                : const CircularProgressIndicator(),
          ),
          if (_initialized)
            SubtitleView(
              controller: _controller,
              position: _positionController.stream,
              style: SubtitleStyle(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: Colors.black54,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startPlayback,
        label: const Text('Play'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}
