import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:subtitle/subtitle.dart';

import 'subtitle_style.dart';

class SubtitleView extends StatefulWidget {
  const SubtitleView({
    super.key,
    required this.controller,
    required this.position,
    this.style = const SubtitleStyle(),
    this.multiLine = false,
  });

  final SubtitleController controller;
  final Stream<Duration> position;
  final SubtitleStyle style;
  final bool multiLine;

  @override
  State<SubtitleView> createState() => _SubtitleViewState();
}

class _SubtitleViewState extends State<SubtitleView> {
  StreamSubscription<Duration>? _subscription;
  String? _currentText;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(SubtitleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position ||
        oldWidget.controller != widget.controller ||
        oldWidget.multiLine != widget.multiLine) {
      _unsubscribe();
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.position.listen(_onPosition);
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _onPosition(Duration position) {
    if (!widget.controller.initialized) return;

    String? text;
    if (widget.multiLine) {
      final subtitles = widget.controller.multiDurationSearch(position);
      if (subtitles.isNotEmpty) {
        text = subtitles.map((s) => s.data).join('\n');
      }
    } else {
      final subtitle = widget.controller.durationSearch(position);
      if (subtitle != null) {
        text = subtitle.data;
      }
    }

    if (text != _currentText) {
      setState(() {
        _currentText = text;
      });
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _currentText;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final style = widget.style;

    return Align(
      alignment: style.alignment,
      child: Container(
        margin: style.margin,
        padding: style.padding,
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: style.borderRadius,
        ),
        child: Text(
          text,
          style: style.textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
