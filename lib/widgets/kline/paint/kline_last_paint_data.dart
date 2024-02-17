import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/paint/configuration.dart';

/// K线最新数据和绘制信息
class KlineLastPaintData {
  KlineLastPaintData({
    required this.last,
    required this.y,
  });

  final double last;
  final double y;

  void paint(Canvas canvas, Size size, Paint paint) {
    if (last == 0 || size.isEmpty) {
      return;
    }

    final textPainter =
        PaintCaches.putIfAbsent('last_line_text', [last, y], () {
      final textSpan = TextSpan(
        text: '$last',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      return textPainter;
    });

    final textOffset = Offset(
      size.width * 0.25,
      y - textPainter.height / 2,
    );

    final rect = Rect.fromLTWH(
      textOffset.dx - 4,
      textOffset.dy - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    final textBackgroundRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(4),
    );

    final linePath = PaintCaches.putIfAbsent(
        'last_line_path', Object.hashAll([y, size.width]), () {
      const dashWidth = 2.0;
      const dashSpace = 2.0;
      double startX = 0;

      final path = Path();
      while (startX < size.width) {
        if (startX > (rect.left - 4) &&
            (startX + dashWidth) < (rect.right + 4)) {
          startX += dashWidth + dashSpace;
          continue;
        }

        path.moveTo(startX, y);
        path.lineTo(startX + dashWidth, y);

        startX += dashWidth + dashSpace;
      }

      return path;
    });

    /// 绘制文本背景
    paint.color = Colors.grey[300]!;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(textBackgroundRect, paint);

    /// 绘制文本
    textPainter.paint(
      canvas,
      textOffset,
    );

    // 绘制虚线
    paint.color = Colors.red;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(linePath, paint);
  }
}
