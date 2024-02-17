import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/kline_configs.dart';

/// k线右侧价格和成交量标题绘制
class KlineRightTitlesPainter {
  static void paint(
      Canvas canvas, Size size, Paint paint, KlinePointsValueRange range) {
    /// 背景
    final rect = Rect.fromLTWH(size.width - KlineConfigs.rightTitlesWidth, 0,
        KlineConfigs.rightTitlesWidth, size.height);
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    /// 价格标题
    final priceHeight = size.height * KlineConfigs.priceHeightRatio;
    for (var i = 1; i < KlineConfigs.priceSegmentCount * 2; i++) {
      final price = range.maxPrice - range.priceInterval * i;
      final heightRate = range.priceInterval * i / range.priceRange;
      if (heightRate >= 1) {
        break;
      }
      final priceY = heightRate * priceHeight;

      PaintCaches.paintText(
        canvas: canvas,
        paint: paint,
        key: 'titles_price_painter_$i',
        text: price.toStringAsFixed(1),
        offset: Offset(rect.left + 4, priceY),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      );
    }

    /// 成交量标题
    final volumeHeight = size.height * KlineConfigs.volumeHeightRatio;
    for (var i = 1; i < KlineConfigs.volumeSegmentCount * 2; i++) {
      final volume = (range.volumeInterval * i).floorToDouble();
      if (volume > range.maxVolume) {
        break;
      }
      final heightRate = volume / range.maxVolume;
      final height = heightRate * volumeHeight;
      PaintCaches.paintText(
        canvas: canvas,
        paint: paint,
        key: 'titles_volume_painter_$i',
        text: volume.toStringAsFixed(0),
        offset: Offset(
          rect.left + 4,
          size.height - height,
        ),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      );
    }
  }
}
