library;

/// Describes the current phase of the vertical scrolling animation.
///
/// Each text item goes through these phases sequentially:
/// 1. [entering] – The text scrolls into the visible area from the bottom.
/// 2. [holding] – The text remains centered and fully visible.
/// 4. [exiting] - The current text scrolls out at the top while the next line scrolls in
/// 3. [cyclePause]  – The text scrolls out of the visible area at the top.

enum TickerPhase {
  /// text scrolls into the visible area from the bottom
  entering,

  /// text remains centered and fully visible
  holding,

  /// current text scrolls out at the top while the next line scrolls in
  exiting,

  /// text scrolls out of the visible area at the top
  cyclePause,
}
