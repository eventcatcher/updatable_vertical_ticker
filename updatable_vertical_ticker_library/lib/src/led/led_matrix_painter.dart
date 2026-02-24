import 'package:flutter/material.dart';
import 'package:updatable_vertical_ticker/src/ticker_phase.dart';
import 'led_bitmap.dart';

/// Painter that renders two lines simultaneously for LED variant
///
/// - current bitnmap scrolls upward
/// - next bitnmap scrolls in from below
/// - empty bitmap is used to show empty matrix (on start to scroll in, and at the end to scroll out)
class LedMatrixPainter extends CustomPainter {
  /// - current bitmap
  final LedBitmap current;

  /// - next bitmap
  final LedBitmap? next;

  /// - empty bitmap
  final LedBitmap empty;

  /// current phase of the vertical scrolling animation
  final TickerPhase phase;

  /// - next progress (0.0 → 1.0)
  final double progress; // 0..1

  /// led dot size in pixels
  final double ledSize;

  /// led gap between dots in pixels
  final double ledGap;

  /// - color of LED is on
  final Color onColor;

  /// - color of LED is off
  final Color offColor;

  /// Creates a [LedMatrixPainter].
  LedMatrixPainter({
    required this.current,
    required this.next,
    required this.empty,
    required this.phase,
    this.progress = 0.0,
    this.ledSize = 10.0,
    this.ledGap = 1.0,
    this.onColor = Colors.red,
    this.offColor = const Color(0xFFdddddd),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double totalHeight = ledSize * 8;

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, totalHeight));

    // different phases of the vertical scrolling animation
    switch (phase) {
      case TickerPhase.entering:
        canvas.save();
        canvas.translate(0, -progress * totalHeight);
        _drawBitmap(canvas, empty);
        canvas.restore();

        canvas.save();
        canvas.translate(0, totalHeight - progress * totalHeight);
        _drawBitmap(canvas, current);
        canvas.restore();
        break;
      case TickerPhase.holding:
        canvas.save();
        canvas.translate(0, 0);
        _drawBitmap(canvas, current);
        canvas.restore();
        break;
      case TickerPhase.exiting:
        canvas.save();
        canvas.translate(0, -progress * totalHeight);
        _drawBitmap(canvas, current);
        canvas.restore();

        if (next != null) {
          canvas.save();
          canvas.translate(0, totalHeight - progress * totalHeight);
          _drawBitmap(canvas, next!);
          canvas.restore();
        }
        break;
      case TickerPhase.cyclePause:
        canvas.save();
        canvas.translate(0, 0);
        _drawBitmap(canvas, empty);
        canvas.restore();
        return;
    }
  }

  // draw bitmap on the canvas
  void _drawBitmap(Canvas canvas, LedBitmap bitmap) {
    for (int row = 0; row < bitmap.height; row++) {
      for (int col = 0; col < bitmap.width; col++) {
        final Paint paint = Paint()
          ..color = bitmap.pixels[row][col] ? onColor : offColor;

        final double dx = col * ledSize;
        final double dy = row * ledSize;
        final Rect rect = Rect.fromLTWH(dx + ledGap / 2, dy + ledGap / 2,
            ledSize - ledGap, ledSize - ledGap);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(ledSize * 0.3)),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LedMatrixPainter oldDelegate) => true;
}
