import 'package:flutter/material.dart';

/// K线最新数据和绘制信息
class KlineLastPaintData {
  KlineLastPaintData({
    required this.last,
    required this.y,
  });

  final double last;
  final double y;

  /// 缓存，需要在主 Isolate 中执行
  TextPainter? _textPainter;
  Offset? _textOffset;
  RRect? _textBackgroundRect;
  Path? _linePath;

  void paint(Canvas canvas, Size size, Paint paint) {
    if (last == 0 || size.isEmpty) {
      return;
    }

    if (_textPainter == null) {
      final textSpan = TextSpan(
        text: '$last',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );

      _textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      _textPainter!.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      _textOffset = Offset(
        size.width * 0.25,
        y - _textPainter!.height / 2,
      );

      final rect = Rect.fromLTWH(
        _textOffset!.dx - 4,
        _textOffset!.dy - 2,
        _textPainter!.width + 8,
        _textPainter!.height + 4,
      );
      _textBackgroundRect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(4),
      );

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

      _linePath = path;
    }

    /// 绘制文本背景
    paint.color = Colors.grey[300]!;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(_textBackgroundRect!, paint);

    /// 绘制文本
    _textPainter!.paint(
      canvas,
      _textOffset!,
    );

    // 绘制虚线
    paint.color = Colors.red;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(_linePath!, paint);
  }
}
