import 'package:flutter/material.dart';
import 'package:updatable_vertical_ticker/src/ticker_phase.dart';

/// Painter that renders two lines simultaneously:
///
/// - currentText scrolls upward
/// - nextText scrolls in from below
class VerticalTickerPainter extends CustomPainter {
  /// Currently visible text.
  final String? currentText;

  /// Next text entering from below.
  final String? nextText;

  /// current phase of the vertical scrolling animation
  final TickerPhase phase;

  /// Scroll progress (0.0 → 1.0).
  final double progress;

  /// Text style.
  final TextStyle textStyle;

  /// Creates a [VerticalTickerPainter].
  ///
  /// All parameters are required and must not be null.
  VerticalTickerPainter({
    required this.currentText,
    required this.nextText,
    required this.phase,
    required this.progress,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double lineHeight = _measureLineHeight();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, lineHeight));

    if (currentText != null) {
      final TextPainter tp = _painter(currentText!);

      double y = 0;
      switch (phase) {
        case TickerPhase.entering:
          y = lineHeight * (1 - progress);
          break;
        case TickerPhase.holding:
          y = 0;
          break;
        case TickerPhase.exiting:
          y = -lineHeight * progress;
          break;
        case TickerPhase.cyclePause:
          return;
      }

      tp.paint(canvas, Offset(_centerX(tp, size), y));
    }

    if (phase == TickerPhase.exiting && nextText != null) {
      final TextPainter tpNext = _painter(nextText!);
      final double yNext = lineHeight * (1 - progress);
      tpNext.paint(canvas, Offset(_centerX(tpNext, size), yNext));
    }

    canvas.restore();
  }

  TextPainter _painter(String text) => TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

  double _measureLineHeight() {
    final tp = _painter('Hg');
    return tp.height;
  }

  double _centerX(TextPainter tp, Size size) => (size.width - tp.width) / 2;

  @override
  bool shouldRepaint(covariant VerticalTickerPainter oldDelegate) =>
      oldDelegate.currentText != currentText ||
      oldDelegate.nextText != nextText ||
      oldDelegate.phase != phase ||
      oldDelegate.progress != progress ||
      oldDelegate.textStyle != textStyle;
}
