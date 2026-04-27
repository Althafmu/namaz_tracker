import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StreakCardShareUtil {
  static Future<Uint8List?> captureCard(GlobalKey cardKey) async {
    try {
      await WidgetsBinding.instance.endOfFrame;

      final context = cardKey.currentContext;
      if (context == null) return null;

      final boundary = context.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return null;

      final image = await boundary.toImage(pixelRatio: 3.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  static Future<void> shareCard(Uint8List bytes, int streakCount) async {
    final tempDir = await getTemporaryDirectory();

    final file = File(
      '${tempDir.path}/falah_streak_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Day $streakCount of staying consistent 🤲\nTrack your prayers with Falah',
    );
  }
}