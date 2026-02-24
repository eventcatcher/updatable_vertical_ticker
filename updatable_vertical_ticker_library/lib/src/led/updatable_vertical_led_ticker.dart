import 'package:flutter/material.dart';
import 'package:updatable_vertical_ticker/src/ticker_phase.dart';
import '../updatable_vertical_ticker.dart';
import 'led_bitmap.dart';
import 'led_matrix_painter.dart';

/// A vertical ticker that scrolls text lines upward continuously.
/// Special Variant which renders a LED matrix display from bitmap font
///
/// The current line scrolls out at the top while the next line
/// scrolls in from the bottom without leaving an empty gap.
///
/// Updates to [texts] are applied only after the current cycle finishes.
class UpdatableVerticalLedTicker extends StatefulWidget {
  /// List of texts to scroll through.
  final List<String> texts;

  /// number of 8x8 LED modules
  final int modules;

  /// use proportional font with different glyph widths
  final bool useProportionalFont;

  /// center text
  final bool center;

  /// led dot size in pixels
  final double ledSize;

  /// led gap between dots in pixels
  final double ledGap;

  /// color of LED is on
  final Color onColor;

  /// color of LED is off
  final Color offColor;

  /// Duration for scrolling from one line to the next
  final Duration scrollDuration;

  /// Delay before the next line starts scrolling
  final Duration linePause;

  /// Delay before the next cycle starts (blank time)
  final Duration cyclePause;

  /// get max width of the text
  final Function(int width)? getMaxWidth;

  /// Creates an [UpdatableVerticalLedTicker]
  const UpdatableVerticalLedTicker({
    super.key,
    required this.texts,
    this.modules = 21,
    this.useProportionalFont = false,
    this.center = true,
    this.ledSize = 10.0,
    this.ledGap = 1.0,
    this.onColor = Colors.red,
    this.offColor = const Color(0xFFdddddd),
    required this.scrollDuration,
    required this.linePause,
    required this.cyclePause,
    this.getMaxWidth,
  });

  @override
  State<UpdatableVerticalLedTicker> createState() =>
      _UpdatableVerticalLedTickerState();
}

class _UpdatableVerticalLedTickerState
    extends State<UpdatableVerticalLedTicker> {
  double maxLineWidth = 0;

  @override
  Widget build(BuildContext context) {
    final double height = widget.ledSize * 8;
    final double width = widget.modules * widget.ledSize * 8;

    if (widget.getMaxWidth != null) {
      if (width != maxLineWidth) {
        maxLineWidth = width;
        widget.getMaxWidth!(maxLineWidth.ceil());
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: UpdatableVerticalTicker(
        texts: widget.texts,
        scrollDuration: widget.scrollDuration,
        linePause: widget.linePause,
        cyclePause: widget.cyclePause,
        textStyle: TextStyle(),
        itemBuilder: (
          BuildContext context,
          String? currentText,
          String? nextText,
          double progress,
          TickerPhase phase,
        ) {
          final LedBitmap currentBitmap = LedBitmap.fromText(
            currentText ?? '',
            modules: widget.modules,
            useProportionalFont: widget.useProportionalFont,
            center: widget.center,
          );
          final LedBitmap nextBitmap = LedBitmap.fromText(
            nextText ?? '',
            modules: widget.modules,
            useProportionalFont: widget.useProportionalFont,
            center: widget.center,
          );
          final LedBitmap emptyBitmap = LedBitmap.fromText(
            '',
            modules: widget.modules,
            useProportionalFont: widget.useProportionalFont,
            center: false,
          );

          return SizedBox(
            height: widget.ledSize * 8,
            width: widget.ledSize * widget.modules * 8,
            child: ClipRect(
              child: CustomPaint(
                painter: LedMatrixPainter(
                  current: currentBitmap,
                  next: nextBitmap,
                  empty: emptyBitmap,
                  phase: phase,
                  progress: progress,
                  ledSize: widget.ledSize,
                  ledGap: widget.ledGap,
                  onColor: widget.onColor,
                  offColor: widget.offColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
