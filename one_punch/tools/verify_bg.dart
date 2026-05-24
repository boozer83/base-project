// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;
void main() {
  for (final f in ['assets/images/6.png', 'assets/images/7.png']) {
    final image = img.decodePng(File(f).readAsBytesSync())!;
    int transparent = 0, opaque = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).a < 10) transparent++; else opaque++;
      }
    }
    final total = image.width * image.height;
    print('$f: 투명=${(transparent/total*100).toStringAsFixed(1)}% 불투명=${(opaque/total*100).toStringAsFixed(1)}%');
    // 코너 확인
    final p = image.getPixel(5, 5);
    print('  코너(5,5): A=${p.a.toInt()} (0=투명 OK)');
  }
}
