import 'package:updatable_vertical_ticker/src/led/cp437_font_proportional.dart';

import 'cp437_font.dart';

/// generates a LED bitmap
class LedBitmap {
  /// Result: rows × columns bitmap
  final List<List<bool>> pixels;

  /// Creates an [LedBitmap].
  LedBitmap(this.pixels);

  /// LED matrix width
  int get width => pixels.isEmpty ? 0 : pixels[0].length;

  /// LED matrix height
  int get height => pixels.length;

  /// generates LED bitmap from text
  static LedBitmap fromText(
    String text, {
    int modules = 21,
    bool useProportionalFont = false,
    bool center = true,
  }) {
    final int cols = modules * 8;
    final int rows = 8;

    // rotate 8x8 Bitmap 90° to the left
    List<List<bool>> rotate90Left(List<List<bool>> matrix) {
      final int rows = matrix.length;
      final int cols = matrix[0].length;
      final List<List<bool>> rotated =
          List.generate(cols, (_) => List<bool>.filled(rows, false));

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (cols - 1 - c < 0) break;
          rotated[cols - 1 - c][r] = matrix[r][c];
        }
      }
      return rotated;
    }

    final List<List<bool>> bitmap =
        List.generate(rows, (int _) => List<bool>.filled(cols, false));

    int colStart = 0;
    if (center == true) {
      int textCols = 0;
      for (int rune in text.runes) {
        final List<int> glyph = useProportionalFont
            ? cp437FontProportional[rune & 0xFF]
            : cp437Font[rune & 0xFF];
        textCols += glyph.length;
      }
      colStart = ((cols - textCols) / 2).floor();
    }

    int xOffset = colStart;
    for (int rune in text.runes) {
      final List<int> glyph = useProportionalFont
          ? cp437FontProportional[rune & 0xFF]
          : cp437Font[rune & 0xFF];

      // generate horizontal Bitmap
      final List<List<bool>> letterBitmap =
          List.generate(glyph.length, (int row) {
        final int rowBits = glyph[row];
        return List.generate(8, (int col) => (rowBits & (1 << (7 - col))) != 0);
      });

      // rotate 8x8 Bitmap 90° to the left
      final rotatedGlyph = rotate90Left(letterBitmap);

      // insert into the bitmap
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < glyph.length; c++) {
          if (xOffset + c >= cols || xOffset + c < 0) break;
          bitmap[r][xOffset + c] = rotatedGlyph[r][c];
        }
      }

      xOffset += glyph.length;
      if (xOffset >= cols) break;
    }

    return LedBitmap(bitmap);
  }
}
