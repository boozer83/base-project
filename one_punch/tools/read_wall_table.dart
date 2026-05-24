// ignore_for_file: avoid_print
import 'dart:io';
import 'package:image/image.dart' as img;

// 체커보드(투명) 배경색 감지: 약 (150,150,150) or (100,100,100) 회색 계열
bool isCheckerboard(img.Pixel p) {
  final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
  final isGray = (r - g).abs() < 15 && (g - b).abs() < 15 && (r - b).abs() < 15;
  final brightness = (r + g + b) ~/ 3;
  return isGray && brightness > 80 && brightness < 200;
}

void main() {
  final bytes = File('5.png').readAsBytesSync();
  final image = img.decodePng(bytes)!;
  final w = image.width, h = image.height;
  print('5.png: ${w}×$h');

  // 배경색 샘플링 (모서리 확인)
  print('\n--- 모서리 픽셀 색상 (배경색 확인) ---');
  for (final pos in [(5, 5), (100, 5), (5, 100), (783, 5), (783, 100)]) {
    final p = image.getPixel(pos.$1, pos.$2);
    print('  (${pos.$1},${pos.$2}): R=${p.r.toInt()} G=${p.g.toInt()} B=${p.b.toInt()} A=${p.a.toInt()}');
  }

  // 체커보드 비율로 행 스프라이트 범위 찾기 (x<900 — 좌측 스프라이트 영역만)
  const scanW = 900;
  print('\n--- 스프라이트 행 범위 (체커보드 아닌 픽셀 기반, x<$scanW) ---');
  bool inRow = false;
  int rowStart = 0;
  final rowBands = <(int, int)>[];
  for (int y = 0; y < h; y++) {
    int spritePx = 0;
    for (int x = 0; x < scanW; x++) {
      if (!isCheckerboard(image.getPixel(x, y))) spritePx++;
    }
    final ratio = spritePx / scanW;
    if (!inRow && ratio > 0.05) { inRow = true; rowStart = y; }
    else if (inRow && ratio <= 0.05) {
      print('  y: $rowStart ~ ${y-1}  h=${y - rowStart}');
      rowBands.add((rowStart, y - 1));
      inRow = false;
    }
  }
  if (inRow) {
    print('  y: $rowStart ~ ${h-1}  h=${h - rowStart}');
    rowBands.add((rowStart, h - 1));
  }

  // 전체 이미지에서 스프라이트 행만 추출 (레이블 행 제외: h<40)
  final spriteRows = rowBands.where((b) => b.$2 - b.$1 >= 40).toList();

  print('\n--- 스프라이트 행만 (h≥40) ---');
  for (int ri = 0; ri < spriteRows.length; ri++) {
    final (ry0, ry1) = spriteRows[ri];
    print('  [$ri] y=$ry0~$ry1 h=${ry1 - ry0 + 1}');
  }

  print('\n--- 각 스프라이트 행별 열 범위 (전체 너비) ---');
  for (int ri = 0; ri < spriteRows.length; ri++) {
    final (ry0, ry1) = spriteRows[ri];
    final midY = (ry0 + ry1) ~/ 2;
    print('\n  [행 $ri] y=$ry0~$ry1 (h=${ry1-ry0+1}, midY=$midY):');

    bool inCol = false;
    int colStart = 0;
    for (int x = 0; x < scanW; x++) {
      int cnt = 0;
      for (int y = ry0; y <= ry1; y++) {
        if (!isCheckerboard(image.getPixel(x, y))) cnt++;
      }
      final ratio = cnt / (ry1 - ry0 + 1);
      if (!inCol && ratio > 0.05) { inCol = true; colStart = x; }
      else if (inCol && ratio <= 0.05) {
        print('    x: $colStart~${x-1}  w=${x - colStart}');
        inCol = false;
      }
    }
    if (inCol) print('    x: $colStart~${scanW-1}  w=${scanW - colStart}');
  }
}
