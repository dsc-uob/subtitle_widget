import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle/subtitle.dart';
import 'package:subtitle_widget/subtitle_widget.dart';

const _srtData = '''
1
00:00:01,000 --> 00:00:04,000
Hello world

2
00:00:05,000 --> 00:00:08,000
Second subtitle

3
00:00:09,000 --> 00:00:12,000
Third line
''';

Future<SubtitleController> _makeController() async {
  final controller = SubtitleController(
    provider: SubtitleProvider.fromString(
      data: _srtData,
      type: SubtitleType.srt,
    ),
  );
  await controller.initial();
  return controller;
}

void main() {
  group('SubtitleView', () {
    testWidgets('displays subtitle text when position is in range',
        (tester) async {
      final controller = await _makeController();
      final positionController = StreamController<Duration>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SubtitleView(
            controller: controller,
            position: positionController.stream,
          ),
        ),
      );

      positionController.add(const Duration(seconds: 2));
      await tester.pump();
      await tester.pump();

      expect(find.text('Hello world'), findsOneWidget);

      positionController.close();
      await controller.dispose();
    });

    testWidgets('shows nothing when no subtitle matches', (tester) async {
      final controller = await _makeController();
      final positionController = StreamController<Duration>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SubtitleView(
            controller: controller,
            position: positionController.stream,
          ),
        ),
      );

      positionController.add(Duration.zero);
      await tester.pump();
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Hello world'), findsNothing);

      positionController.close();
      await controller.dispose();
    });

    testWidgets('updates when position stream emits new value', (tester) async {
      final controller = await _makeController();
      final positionController = StreamController<Duration>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SubtitleView(
            controller: controller,
            position: positionController.stream,
          ),
        ),
      );

      positionController.add(const Duration(seconds: 2));
      await tester.pump();
      await tester.pump();
      expect(find.text('Hello world'), findsOneWidget);

      positionController.add(const Duration(seconds: 6));
      await tester.pump();
      await tester.pump();
      expect(find.text('Second subtitle'), findsOneWidget);
      expect(find.text('Hello world'), findsNothing);

      positionController.close();
      await controller.dispose();
    });

    testWidgets('shows nothing before controller is initialized',
        (tester) async {
      final controller = SubtitleController(
        provider: SubtitleProvider.fromString(
          data: _srtData,
          type: SubtitleType.srt,
        ),
      );

      final positionController = StreamController<Duration>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SubtitleView(
            controller: controller,
            position: positionController.stream,
          ),
        ),
      );

      positionController.add(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Hello world'), findsNothing);

      positionController.close();
      await controller.dispose();
    });

    testWidgets('multiLine joins multiple active subtitles with newline',
        (tester) async {
      const multiSrt = '''
1
00:00:01,000 --> 00:00:05,000
Line one

2
00:00:03,000 --> 00:00:07,000
Line two
''';
      final controller = SubtitleController(
        provider: SubtitleProvider.fromString(
          data: multiSrt,
          type: SubtitleType.srt,
        ),
      );
      await controller.initial();

      final positionController = StreamController<Duration>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SubtitleView(
            controller: controller,
            position: positionController.stream,
            multiLine: true,
          ),
        ),
      );

      positionController.add(const Duration(seconds: 4));
      await tester.pump();
      await tester.pump();

      expect(find.text('Line one\nLine two'), findsOneWidget);

      positionController.close();
      await controller.dispose();
    });
  });
}
