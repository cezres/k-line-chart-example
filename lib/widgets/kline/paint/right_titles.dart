import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/paint/configuration.dart';

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
    final rect = Rect.fromLTWH(size.width - KlinePaintConfigs.rightTitlesWidth,
        0, KlinePaintConfigs.rightTitlesWidth, size.height);
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);

    /// 价格标题
    final priceHeight = size.height * KlinePaintConfigs.priceHeightRatio;
    final priceItemHeight = priceHeight / KlinePaintConfigs.priceSegmentCount;
    for (var i = 1; i < KlinePaintConfigs.priceSegmentCount; i++) {
      final price = range.maxPrice - range.priceInterval * i;
      final textPainter =
          PaintCaches.putIfAbsent('titles_price_painter_$i', price, (value) {
        final textSpan = TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
        );
        final textPainter =
            TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(
            minWidth: 0, maxWidth: KlinePaintConfigs.rightTitlesWidth);
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
    final volumeHeight = size.height * KlinePaintConfigs.volumeHeightRatio;
    final volumeItemHeight =
        volumeHeight / KlinePaintConfigs.volumeSegmentCount;
    final volumeBaseY = size.height - volumeHeight;
    for (var i = 0; i < KlinePaintConfigs.volumeSegmentCount; i++) {
      final volume = range.maxVolume - range.volumeInterval * i;
      final textPainter =
          PaintCaches.putIfAbsent('titles_volume_painter_$i', volume, (value) {
        final textSpan = TextSpan(
          text: value.toStringAsFixed(0),
          style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
        );
        final textPainter =
            TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(
            minWidth: 0, maxWidth: KlinePaintConfigs.rightTitlesWidth);
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
