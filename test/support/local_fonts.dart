import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Structural widget tests use the SDK font, never download production fonts.
/// These tests do not establish typography/golden parity.
Future<void> installLocalTestFonts() async {
  var directory = File(Platform.resolvedExecutable).parent;
  File? font;
  while (directory.parent.path != directory.path) {
    final candidate = File('${directory.path}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
    if (candidate.existsSync()) { font = candidate; break; }
    directory = directory.parent;
  }
  if (font == null) throw StateError('Flutter SDK test font unavailable');
  final bytes = Uint8List.fromList(await font.readAsBytes());
  final manifestData = await rootBundle.load('AssetManifest.bin');
  final manifest = Map<Object?, Object?>.from(const StandardMessageCodec().decodeMessage(manifestData) as Map);
  for (final family in ['Inter', 'Lato']) {
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold', 'Black']) {
      final name = 'test-fonts/$family-$weight.ttf';
      manifest[name] = [{'asset': name}];
    }
  }
  GoogleFonts.config.allowRuntimeFetching = false;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
    final name = const StringCodec().decodeMessage(message)!;
    if (name == 'AssetManifest.bin') return const StandardMessageCodec().encodeMessage(manifest);
    if (name.startsWith('test-fonts/')) return ByteData.sublistView(bytes);
    // Delegate real images and other assets to the test asset directory.
    final file = File('build/unit_test_assets/$name');
    return file.existsSync() ? ByteData.sublistView(await file.readAsBytes()) : null;
  });
}
