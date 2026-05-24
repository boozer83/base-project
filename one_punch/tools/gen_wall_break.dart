import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  const sr = 22050;
  const dur = 0.65;
  final n = (sr * dur).toInt();
  final rng = Random(42);

  final samples = List<double>.generate(n, (i) {
    final t = i / sr;
    final crack = (rng.nextDouble() * 2 - 1) * exp(-t * 55);
    final thud  = sin(2 * pi * 75 * t) * exp(-t * 10);
    final rumble = (rng.nextDouble() * 2 - 1) * exp(-t * 5);
    return (crack * 1.4 + thud * 0.9 + rumble * 0.35).clamp(-1.0, 1.0);
  });

  double peak = samples.map((s) => s.abs()).reduce(max);
  if (peak > 0) {
    for (int i = 0; i < n; i++) samples[i] = samples[i] / peak * 0.92;
  }

  final buf = BytesBuilder();
  void u32(int v) { buf.addByte(v & 0xFF); buf.addByte((v >> 8) & 0xFF); buf.addByte((v >> 16) & 0xFF); buf.addByte((v >> 24) & 0xFF); }
  void u16(int v) { buf.addByte(v & 0xFF); buf.addByte((v >> 8) & 0xFF); }
  void str(String s) { buf.add(s.codeUnits); }

  final dataSize = n * 2;
  str('RIFF'); u32(dataSize + 36); str('WAVE');
  str('fmt '); u32(16); u16(1); u16(1); u32(sr); u32(sr * 2); u16(2); u16(16);
  str('data'); u32(dataSize);

  final pcm = ByteData(dataSize);
  for (int i = 0; i < n; i++) {
    pcm.setInt16(i * 2, (samples[i] * 32767).round().clamp(-32768, 32767), Endian.little);
  }
  buf.add(pcm.buffer.asUint8List());

  final out = File('one_punch/assets/audio/wall_break.wav');
  out.writeAsBytesSync(buf.toBytes());
  print('Generated ${out.path} (${out.lengthSync()} bytes)');
}
