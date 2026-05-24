// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

bool isDark(img.Pixel p) {
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  return r < 30 && g < 30 && b < 30;
}

void main() {
  final bytes = File('3.png').readAsBytesSync();
  final image = img.decodePng(bytes)!;
  final w = image.width;
  final h = image.height;
  print('Image: ${w}×$h');

  // Scan each row: fraction of near-black pixels
  final rowDark = <double>[];
  for (int y = 0; y < h; y++) {
    int count = 0;
    for (int x = 0; x < w; x++) {
      if (isDark(image.getPixel(x, y))) count++;
    }
    rowDark.add(count / w);
  }

  // Scan each column: fraction of near-black pixels
  final colDark = <double>[];
  for (int x = 0; x < w; x++) {
    int count = 0;
    for (int y = 0; y < h; y++) {
      if (isDark(image.getPixel(x, y))) count++;
    }
    colDark.add(count / h);
  }

  // Find row separator bands (very high dark fraction = separator lines)
  print('\n--- Row separators (dark > 90%) ---');
  bool inSep = false;
  int sepStart = 0;
  for (int y = 0; y < h; y++) {
    if (!inSep && rowDark[y] > 0.90) { inSep = true; sepStart = y; }
    else if (inSep && rowDark[y] <= 0.90) {
      print('  y: $sepStart-${y-1} (mid=${(sepStart+y-1)~/2})');
      inSep = false;
    }
  }

  // Find row separator bands (dark > 70%)
  print('\n--- Row separators (dark > 70%) ---');
  inSep = false;
  for (int y = 0; y < h; y++) {
    if (!inSep && rowDark[y] > 0.70) { inSep = true; sepStart = y; }
    else if (inSep && rowDark[y] <= 0.70) {
      print('  y: $sepStart-${y-1} (mid=${(sepStart+y-1)~/2})');
      inSep = false;
    }
  }

  // Print row dark ratios
  print('\n--- Row dark% (every 8px) ---');
  for (int y = 0; y < h; y += 8) {
    final d = (rowDark[y] * 100).toStringAsFixed(0).padLeft(3);
    final bar = '█' * (rowDark[y] * 40).round();
    print('  y=${y.toString().padLeft(4)}: $d% $bar');
  }

  // Find column separator bands in char area (x < 1000)
  print('\n--- Column separators in char area (dark > 90%) ---');
  bool inCSep = false;
  int cSepStart = 0;
  for (int x = 0; x < 1000; x++) {
    if (!inCSep && colDark[x] > 0.90) { inCSep = true; cSepStart = x; }
    else if (inCSep && colDark[x] <= 0.90) {
      print('  x: $cSepStart-${x-1} (${x - cSepStart}px, mid=${(cSepStart+x-1)~/2})');
      inCSep = false;
    }
  }

  // Wall area column separators
  print('\n--- Column separators in wall area (dark > 90%) ---');
  bool inWSep = false;
  int wSepStart = 0;
  for (int x = 1000; x < w; x++) {
    if (!inWSep && colDark[x] > 0.90) { inWSep = true; wSepStart = x; }
    else if (inWSep && colDark[x] <= 0.90) {
      print('  x: $wSepStart-${x-1} (${x - wSepStart}px, mid=${(wSepStart+x-1)~/2})');
      inWSep = false;
    }
  }

  // Col dark ratios for char area
  print('\n--- Col dark% char area (every 8px) ---');
  for (int x = 0; x < 1000; x += 8) {
    final d = (colDark[x] * 100).toStringAsFixed(0).padLeft(3);
    final bar = '█' * (colDark[x] * 40).round();
    print('  x=${x.toString().padLeft(4)}: $d% $bar');
  }

  print('\n--- Col dark% wall area (every 8px) ---');
  for (int x = 1000; x < w; x += 8) {
    final d = (colDark[x] * 100).toStringAsFixed(0).padLeft(3);
    final bar = '█' * (colDark[x] * 40).round();
    print('  x=${x.toString().padLeft(4)}: $d% $bar');
  }
}
