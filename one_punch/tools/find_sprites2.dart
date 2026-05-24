// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

// 투명도 기반으로 스프라이트 행/열 경계 찾기 (투명 배경 이미지용)
void analyzeTransparent(String path) {
  final bytes = File(path).readAsBytesSync();
  final image = img.decodePng(bytes)!;
  final w = image.width, h = image.height;
  print('\n=== $path ===');
  print('Size: ${w}×$h');

  // 행별 비투명 픽셀 비율
  final rowOpaque = <double>[];
  for (int y = 0; y < h; y++) {
    int cnt = 0;
    for (int x = 0; x < w; x++) {
      if (image.getPixel(x, y).a > 20) cnt++;
    }
    rowOpaque.add(cnt / w);
  }

  // 열별 비투명 픽셀 비율
  final colOpaque = <double>[];
  for (int x = 0; x < w; x++) {
    int cnt = 0;
    for (int y = 0; y < h; y++) {
      if (image.getPixel(x, y).a > 20) cnt++;
    }
    colOpaque.add(cnt / h);
  }

  // 행 경계 찾기: transparent(≤1%) → opaque 전환 지점
  print('\n--- 스프라이트 행 범위 (투명→내용→투명) ---');
  bool inSprite = false;
  int rowStart = 0;
  for (int y = 0; y < h; y++) {
    if (!inSprite && rowOpaque[y] > 0.01) { inSprite = true; rowStart = y; }
    else if (inSprite && rowOpaque[y] <= 0.01) {
      print('  y: $rowStart ~ ${y-1}  (height=${y - rowStart})');
      inSprite = false;
    }
  }
  if (inSprite) print('  y: $rowStart ~ ${h-1}  (height=${h - rowStart})');

  // 전체 행 밀도 (5px 간격)
  print('\n--- 행 내용 밀도 (5px간격) ---');
  for (int y = 0; y < h; y += 5) {
    final d = (rowOpaque[y] * 100).toStringAsFixed(0).padLeft(3);
    final bar = '█' * (rowOpaque[y] * 50).round();
    if (rowOpaque[y] > 0.01) print('  y=${y.toString().padLeft(4)}: $d% $bar');
  }

  // 열 경계 찾기
  print('\n--- 스프라이트 열 범위 ---');
  bool inColSprite = false;
  int colStart = 0;
  for (int x = 0; x < w; x++) {
    if (!inColSprite && colOpaque[x] > 0.01) { inColSprite = true; colStart = x; }
    else if (inColSprite && colOpaque[x] <= 0.01) {
      print('  x: $colStart ~ ${x-1}  (width=${x - colStart})');
      inColSprite = false;
    }
  }
  if (inColSprite) print('  x: $colStart ~ ${w-1}  (width=${w - colStart})');
}

void main() {
  analyzeTransparent('4.png');
  analyzeTransparent('5.png');
}
