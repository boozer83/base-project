import 'dart:io';

void main() {
  final f = File('3.png');
  final bytes = f.readAsBytesSync();
  final w = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
  final h = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
  print('Width: $w, Height: $h');
  print('File size: ${f.lengthSync()} bytes');
  // 스프라이트 그리드 추정
  // 캐릭터 5종 + 이펙트 1줄 = 6행
  // 벽 7종
  print('');
  print('캐릭터 영역 (왼쪽 ~60%): ${(w * 0.60).toInt()}px');
  print('벽 영역 (오른쪽 ~40%): ${(w * 0.40).toInt()}px');
  print('캐릭터 1행 높이 추정: ${(h / 7).toInt()}px (6캐릭터행+이펙트)');
  print('벽 1행 높이 추정: ${(h / 8).toInt()}px (7벽종+아이템)');
}
