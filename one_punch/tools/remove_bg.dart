// ignore_for_file: avoid_print
import 'dart:collection';
import 'dart:io';
import 'package:image/image.dart' as img;

// 초록 크로마키 배경 판별: G가 R·B보다 훨씬 높고 밝은 초록
bool isGreen(img.Pixel p) {
  final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
  return g > 150 && g > r * 3 && g > b * 4;
}

img.Image removeBg(img.Image src) {
  final w = src.width, h = src.height;
  // RGBA 결과 이미지 (투명 초기화)
  final out = img.Image(width: w, height: h, numChannels: 4);

  // 원본 픽셀 복사
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final p = src.getPixel(x, y);
      out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 255);
    }
  }

  // BFS 플러드필: 가장자리에서 시작해 연결된 초록 픽셀 제거
  final visited = List.generate(h, (_) => List.filled(w, false));
  final queue = Queue<(int, int)>();

  void enqueue(int x, int y) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    if (visited[y][x]) return;
    if (!isGreen(src.getPixel(x, y))) return;
    visited[y][x] = true;
    queue.add((x, y));
  }

  // 상·하·좌·우 가장자리 씨드
  for (int x = 0; x < w; x++) { enqueue(x, 0); enqueue(x, h - 1); }
  for (int y = 0; y < h; y++) { enqueue(0, y); enqueue(w - 1, y); }

  while (queue.isNotEmpty) {
    final (x, y) = queue.removeFirst();
    out.setPixelRgba(x, y, 0, 0, 0, 0); // 투명
    enqueue(x + 1, y); enqueue(x - 1, y);
    enqueue(x, y + 1); enqueue(x, y - 1);
  }

  return out;
}

void main() {
  for (final entry in {'6.png': 'assets/images/6.png', '7.png': 'assets/images/7.png'}.entries) {
    final src = entry.key;
    final dst = entry.value;
    if (!File(src).existsSync()) { print('$src not found'); continue; }
    print('Processing $src ...');
    final image = img.decodePng(File(src).readAsBytesSync())!;
    final result = removeBg(image);
    File(dst).writeAsBytesSync(img.encodePng(result));
    print('  → $dst (${result.width}x${result.height}, transparent bg)');
  }
  print('Done!');
}
