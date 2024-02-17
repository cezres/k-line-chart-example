import 'package:flutter/material.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_configs.dart';

/// K线最新数据和绘制信息
class KlineLastPaintData {
  KlineLastPaintData({
    required this.last,
    required this.y,
    required this.isRise,
  });

  final double last;
  final double y;
  final bool isRise;

  void paint(Canvas canvas, Size size, Paint paint) {
    if (last == 0 || size.isEmpty) {
      return;
    }

    final rect = PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'last_line_text',
      text: last.toStringAsFixed(1),
      offset: Offset(
        size.width * 0.25,
        y,
      ),
      style: const TextStyle(color: Colors.black, fontSize: 12),
      backgroundColor: Colors.grey[300]!,
      backgroundRadius: const Radius.circular(4),
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

    // 绘制虚线
    paint.color = isRise ? KlineConfigs.riseColor : KlineConfigs.fallColor;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(linePath, paint);
  }
}
