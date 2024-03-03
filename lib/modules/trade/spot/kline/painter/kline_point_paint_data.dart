import 'package:flutter/material.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_configs.dart';

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

  final double openPriceY;
  final double closePriceY;
  final double lowPriceY;
  final double highPriceY;
  final double volumeY;

  KlinePointPaintData copyWith({
    int? distance,
    double? distanceX,
    double? openPriceY,
    double? closePriceY,
    double? lowPriceY,
    double? highPriceY,
    double? volumeY,
  }) {
    return KlinePointPaintData(
      distance: distance ?? this.distance,
      distanceX: distanceX ?? this.distanceX,
      openPriceY: openPriceY ?? this.openPriceY,
      closePriceY: closePriceY ?? this.closePriceY,
      lowPriceY: lowPriceY ?? this.lowPriceY,
      highPriceY: highPriceY ?? this.highPriceY,
      volumeY: volumeY ?? this.volumeY,
    );
  }

  void paint(Canvas canvas, Size size, Paint paint, double segmentWidth, double scrollOffset) {
    final displayX = size.width - (distanceX - scrollOffset);
    if (displayX > size.width || displayX < -20) {
      return;
    }

    final x = displayX - segmentWidth / 2;
    paint.color = closePriceY < openPriceY ? KlineConfigs.riseColor : KlineConfigs.fallColor;

    paint.strokeWidth = segmentWidth - 1;
    final openCloseAbs = (openPriceY - closePriceY).abs();
    if (openCloseAbs < 1) {
      if (closePriceY > openPriceY) {
        canvas.drawLine(
          Offset(x, openPriceY),
          Offset(x, openPriceY + 1),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(x, closePriceY),
          Offset(x, closePriceY - 1),
          paint,
        );
      }
    } else {
      canvas.drawLine(
        Offset(x, openPriceY),
        Offset(x, closePriceY),
        paint,
      );
    }

    if (segmentWidth > 3) {
      paint.strokeWidth = 1;
      canvas.drawLine(
        Offset(x, highPriceY),
        Offset(x, lowPriceY),
        paint,
      );
    }

    paint.color = closePriceY < openPriceY ? KlineConfigs.volumeRiseColor : KlineConfigs.volumeFallColor;
    paint.strokeWidth = segmentWidth - 1;
    canvas.drawLine(
      Offset(x, size.height),
      Offset(x, volumeY),
      paint,
    );
  }
}
