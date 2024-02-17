import 'package:flutter/material.dart';

/// K线点绘制数据
class KlinePointPaintData {
  KlinePointPaintData({
    required this.distance,
    required this.distanceX,
    // required this.x,
    required this.openPriceY,
    required this.closePriceY,
    required this.lowPriceY,
    required this.highPriceY,
    required this.volumeY,
  });

  /// K线点数据距离最新数据的索引偏移
  final int distance;

  /// K线点数据距离最新数据的X坐标偏移 distance * segmentWidth
  final double distanceX;
  // final double x;

  final double openPriceY;
  final double closePriceY;
  final double lowPriceY;
  final double highPriceY;
  final double volumeY;

  void paint(Canvas canvas, Size size, Paint paint, double segmentWidth,
      double scrollOffset) {
    final displayX = size.width - (distanceX - scrollOffset);
    if (displayX > size.width || displayX < -20) {
      return;
    }

    final x = displayX - segmentWidth / 2;
    paint.color = closePriceY < openPriceY ? Colors.red : Colors.green;

    paint.strokeWidth = segmentWidth - 1;
    canvas.drawLine(
      Offset(x, openPriceY),
      Offset(x, closePriceY),
      paint,
    );

    canvas.drawLine(
      Offset(x, size.height),
      Offset(x, volumeY),
      paint,
    );

    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(x, highPriceY),
      Offset(x, lowPriceY),
      paint,
    );
  }
}
