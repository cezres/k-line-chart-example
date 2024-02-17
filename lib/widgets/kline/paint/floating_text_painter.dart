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
      text: '成交量(Volume)',
      offset: Offset(20, size.height * (1 - KlineConfigs.volumeHeightRatio)),
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_price_title',
      text: '开=                高=                 低=                 收=',
      offset: const Offset(20, 20),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );

    var point = data.kline.points.last;
    if (data.mousePositionX > 0 &&
        data.mousePositionX < size.width - KlineConfigs.rightTitlesWidth) {
      final distanceX = size.width - data.mousePositionX + data.scrollOffset;
      if (distanceX >= 0) {
        final index =
            data.points.indexWhere((element) => element.distanceX < distanceX);
        point = data.kline.points[index];
        debugPrint('distanceX: $distanceX - $index ${data.points.length}');
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
          '${point.open}       ${point.high}        ${point.low}        ${point.close}',
      offset: const Offset(20 + 22, 20),
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
          Offset(20 + 90, size.height * (1 - KlineConfigs.volumeHeightRatio)),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
