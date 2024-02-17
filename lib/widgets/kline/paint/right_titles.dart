import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/kline_configs.dart';

/// k线右侧价格和成交量标题绘制
class KlineRightTitlesPaintData {
  final double maxPrice;
  final double minPrice;
  final double priceInterval;

  final double maxVolume;
  final double volumeInterval;

  KlineRightTitlesPaintData({
    required this.maxPrice,
    required this.minPrice,
    required this.priceInterval,
    required this.maxVolume,
    required this.volumeInterval,
  });
}

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
    final priceItemHeight = priceHeight / KlineConfigs.priceSegmentCount;
    for (var i = 1; i < KlineConfigs.priceSegmentCount; i++) {
      final price = range.maxPrice - range.priceInterval * i;
      final textPainter =
          PaintCaches.putIfAbsent('titles_price_painter_$i', price, () {
        final textSpan = TextSpan(
          text: price.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
        );
        final textPainter =
            TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(
            minWidth: 0, maxWidth: KlineConfigs.rightTitlesWidth);
        return textPainter;
      });
      textPainter.paint(
        canvas,
        Offset(
          rect.left + 4,
          priceItemHeight * i - textPainter.height / 2,
        ),
      );
    }

    /// 成交量标题
    final volumeHeight = size.height * KlineConfigs.volumeHeightRatio;
    final volumeItemHeight = volumeHeight / KlineConfigs.volumeSegmentCount;
    final volumeBaseY = size.height - volumeHeight;
    for (var i = 0; i < KlineConfigs.volumeSegmentCount; i++) {
      final volume = range.maxVolume - range.volumeInterval * i;
      final textPainter =
          PaintCaches.putIfAbsent('titles_volume_painter_$i', volume, () {
        final textSpan = TextSpan(
          text: volume.toStringAsFixed(0),
          style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
        );
        final textPainter =
            TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(
            minWidth: 0, maxWidth: KlineConfigs.rightTitlesWidth);
        return textPainter;
      });
      textPainter.paint(
        canvas,
        Offset(
          rect.left + 4,
          volumeBaseY + volumeItemHeight * i - textPainter.height / 2,
        ),
      );
    }
  }
}
