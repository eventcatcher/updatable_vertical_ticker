import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:updatable_vertical_ticker/src/ticker_phase.dart';
import 'package:updatable_vertical_ticker/src/vertical_ticker_painter.dart';

/// typedef
typedef VerticalTickerItemBuilder = Widget Function(
  BuildContext context,
  String? currentText,
  String? nextText,
  double progress,
  TickerPhase phase,
);

/// A vertical ticker that scrolls text lines upward continuously.
///
/// The current line scrolls out at the top while the next line
/// scrolls in from the bottom without leaving an empty gap.
///
/// Updates to [texts] are applied only after the current cycle finishes.
class UpdatableVerticalTicker extends StatefulWidget {
  /// List of texts to scroll through
  final List<String> texts;

  /// Duration for scrolling from one line to the next
  final Duration scrollDuration;

  /// Delay before the next line starts scrolling
  final Duration linePause;

  /// Delay before the next cycle starts (blank time)
  final Duration cyclePause;

  /// Text style used for rendering
  final TextStyle textStyle;

  /// get max width of the text
  final Function(int width)? getMaxWidth;

  /// Optional custom renderer
  final VerticalTickerItemBuilder? itemBuilder;

  /// Creates an [UpdatableVerticalTicker].
  const UpdatableVerticalTicker({
    super.key,
    required this.texts,
    required this.scrollDuration,
    required this.linePause,
    required this.cyclePause,
    required this.textStyle,
    this.getMaxWidth,
    this.itemBuilder,
  });

  @override
  State<UpdatableVerticalTicker> createState() =>
      _UpdatableVerticalTickerState();
}

class _UpdatableVerticalTickerState extends State<UpdatableVerticalTicker>
    with SingleTickerProviderStateMixin {
  late List<String> _activeTexts;
  List<String>? _pendingTexts;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Duration _phaseElapsed = Duration.zero;

  int _currentIndex = 0;
  double _progress = 0.0;
  double maxLineWidth = 0;
  TickerPhase _phase = TickerPhase.entering;

  @override
  void initState() {
    super.initState();
    _activeTexts = List.of(widget.texts);

    _currentIndex = 0;
    _progress = 0.0;
    _phaseElapsed = Duration.zero;

    if (_activeTexts.isEmpty) {
      _phase = TickerPhase.cyclePause;
    } else {
      _phase = TickerPhase.entering;
    }

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant UpdatableVerticalTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.texts, widget.texts)) {
      _pendingTexts = List.of(widget.texts);
    }
  }

  void _onTick(Duration elapsed) {
    final Duration delta = elapsed - _lastTick;
    _lastTick = elapsed;
    _phaseElapsed += delta;

    switch (_phase) {
      case TickerPhase.entering:
        _progress +=
            delta.inMilliseconds / widget.scrollDuration.inMilliseconds;

        if (_progress >= 1.0) {
          _progress = 1.0;
          _phaseElapsed = Duration.zero;
          _phase = TickerPhase.holding;
        }
        break;

      case TickerPhase.holding:
        if (_phaseElapsed >= widget.linePause) {
          _phaseElapsed = Duration.zero;
          _progress = 0.0;
          _phase = TickerPhase.exiting;
        }
        break;

      case TickerPhase.exiting:
        _progress +=
            delta.inMilliseconds / widget.scrollDuration.inMilliseconds;

        if (_progress >= 1.0) {
          _progress = 0.0;
          _phaseElapsed = Duration.zero;
          _currentIndex++;

          if (_currentIndex >= _activeTexts.length) {
            // last text is out
            _phase = TickerPhase.cyclePause;
          } else {
            // next text is coming in
            _phase = TickerPhase.holding;
          }
        }
        break;

      case TickerPhase.cyclePause:
        if (_phaseElapsed >= widget.cyclePause) {
          _phaseElapsed = Duration.zero;
          _currentIndex = 0;
          _progress = 0.0;
          _phase = TickerPhase.entering;

          if (_pendingTexts != null) {
            _activeTexts = _pendingTexts!;
            _pendingTexts = null;
          }
        }
        break;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeTexts.isEmpty) {
      return const SizedBox.shrink();
    }

    final String? currentText = _currentIndex < _activeTexts.length
        ? _activeTexts[_currentIndex]
        : null;

    final String? nextText = (_currentIndex + 1) < _activeTexts.length
        ? _activeTexts[_currentIndex + 1]
        : null;

    // CUSTOM BUILDER
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(
        context,
        currentText,
        nextText,
        _progress,
        _phase,
      );
    }

    // Determine exact line height
    TextPainter tp = TextPainter(
      text: TextSpan(text: 'Hg', style: widget.textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final double lineHeight = tp.height;

    if (widget.getMaxWidth != null) {
      double lineWidth = maxLineWidth;
      // Determine max line width
      for (String line in _activeTexts) {
        tp = TextPainter(
          text: TextSpan(text: line, style: widget.textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        if (tp.width > maxLineWidth) {
          lineWidth = tp.width;
        }
      }

      if (lineWidth > maxLineWidth) {
        maxLineWidth = lineWidth;
        widget.getMaxWidth!(maxLineWidth.ceil());
      }
    }

    return SizedBox(
      height: lineHeight,
      width: double.infinity,
      child: ClipRect(
        child: CustomPaint(
          painter: VerticalTickerPainter(
            currentText: currentText,
            nextText: nextText,
            phase: _phase,
            progress: _progress,
            textStyle: widget.textStyle,
          ),
        ),
      ),
    );
  }
}
