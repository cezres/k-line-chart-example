import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/kline_configs.dart';
import 'package:gateio_flutter/widgets/kline/paint/kline_paint_data.dart';

class KlineFloatingTextPainter {
  static void paint(
      Canvas canvas, Size size, Paint paint, KlinePaintData data) {
    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_volume_title',
      text: 'Volume',
      offset: Offset(20, size.height * (1 - KlineConfigs.volumeHeightRatio)),
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_price_title',
      text:
          'Open:                High:                 low:                 Close:',
      offset: const Offset(10, 20),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );

    var point = data.kline.last;
    if (data.mousePositionX > 0 &&
        data.mousePositionX < size.width - KlineConfigs.rightTitlesWidth) {
      final distanceX = size.width - data.mousePositionX + data.scrollOffset;
      if (distanceX >= 0) {
        final index =
            data.points.indexWhere((element) => element.distanceX < distanceX);
        point = data.kline.points[index];
      }
    }

    final color = point.close > point.open
        ? KlineConfigs.riseColor
        : KlineConfigs.fallColor;

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_price_value',
      text:
          '${point.open.toStringAsFixed(1)}           ${point.high.toStringAsFixed(1)}         ${point.low.toStringAsFixed(1)}             ${point.close.toStringAsFixed(1)}',
      offset: const Offset(10 + 34, 20),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_volume_value',
      text: point.baseVolume.toString(),
      offset:
          Offset(20 + 46, size.height * (1 - KlineConfigs.volumeHeightRatio)),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
