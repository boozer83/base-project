// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;
void main() {
  for (final f in ['6.png', '7.png']) {
    if (!File(f).existsSync()) { print('$f not found'); continue; }
    final image = img.decodePng(File(f).readAsBytesSync())!;
    final w = image.width, h = image.height;
    final samples = [
      (5, 5), (w ~/ 2, 5), (w - 5, 5),
      (5, h - 5), (w ~/ 2, h - 5), (w - 5, h - 5),
    ];
    print('$f ${w}x$h');
    for (final (x, y) in samples) {
      final p = image.getPixel(x, y);
      print('  ($x,$y): R=${p.r.toInt()} G=${p.g.toInt()} B=${p.b.toInt()} A=${p.a.toInt()}');
    }
  }
}
