import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_configs.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_paint_data.dart';

class KlineFloatingTextPainter {
  static void paint(Canvas canvas, Size size, Paint paint, KlinePaintData data) {
    var point = data.kline.last;
    if (data.mousePositionX > 0 && data.mousePositionX < size.width - KlineConfigs.rightTitlesWidth) {
      final distanceX = size.width - data.mousePositionX + data.scrollOffset;
      if (distanceX >= 0) {
        final index = data.points.indexWhere((element) => element.distanceX < distanceX);
        if (index >= 0) {
          point = data.kline.points[index];
        }
      }
    }

    final double fontSize;
    final double titleOffset;
    final double valueOffset;
    final String priceTitle;
    final String priceValue;
    final String volumeValue;

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      titleOffset = 20;
      valueOffset = 56;
      fontSize = 12;
      priceTitle = 'Open:                High:                 Low:                 Close:';
      priceValue =
          '${point.open.toStringAsFixed(1)}           ${point.high.toStringAsFixed(1)}         ${point.low.toStringAsFixed(1)}             ${point.close.toStringAsFixed(1)}';
      volumeValue = '    ${point.baseVolume}';
    } else {
      titleOffset = 12;
      valueOffset = 30;
      fontSize = 10;
      priceTitle = 'Open:                High:                 Low:                 Close:';
      priceValue =
          '  ${point.open.toStringAsFixed(1)}           ${point.high.toStringAsFixed(1)}         ${point.low.toStringAsFixed(1)}             ${point.close.toStringAsFixed(1)}';
      volumeValue = '     ${point.baseVolume}';
    }

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_price_title',
      text: priceTitle,
      offset: Offset(titleOffset, 0),
      style: TextStyle(
        color: Colors.grey,
        fontSize: fontSize,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    final color = point.close > point.open ? KlineConfigs.riseColor : KlineConfigs.fallColor;

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_price_value',
      text: priceValue,
      offset: Offset(valueOffset, 0),
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_volume_title',
      text: 'Volume:',
      offset: Offset(titleOffset, size.height * (1 - KlineConfigs.volumeHeightRatio)),
      style: TextStyle(color: Colors.grey, fontSize: fontSize),
    );

    PaintCaches.paintText(
      canvas: canvas,
      paint: paint,
      key: 'floating_text_volume_value',
      text: volumeValue,
      offset: Offset(valueOffset, size.height * (1 - KlineConfigs.volumeHeightRatio)),
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
