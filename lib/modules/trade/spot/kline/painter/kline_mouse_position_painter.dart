import 'package:flutter/material.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_configs.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_paint_data.dart';

class KlineMousePositionPainter {
  static void paint(Canvas canvas, Size size, Paint paint, KlinePaintData data) {
    if (data.mousePositionX < 10 ||
        data.mousePositionX > size.width - KlineConfigs.rightTitlesWidth ||
        data.mousePositionY < 0 ||
        data.mousePositionY > size.height - KlineConfigs.bottomTitlesHeight) {
      return;
    }

    /// 绘制交叉线
    final linePath = Path();
    PaintCaches.setupHorizontalDottedLinePath(
      path: linePath,
      start: 0,
      end: size.width,
      y: data.mousePositionY,
      dashWidth: 4,
      dashSpace: 4,
    );
    PaintCaches.setupVerticalDottedLinePath(
      path: linePath,
      start: 0,
      end: size.height,
      x: data.mousePositionX,
      dashWidth: 4,
      dashSpace: 4,
    );
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawPath(linePath, paint);

    final valueRange = data.kline.valueRange;

    /// 绘制右侧价格
    final priceHeight = size.height * KlineConfigs.priceHeightRatio;
    if (data.mousePositionY < priceHeight) {
      final valueRatio = (priceHeight - data.mousePositionY) / priceHeight;
      final price = valueRange.minPrice + valueRatio * valueRange.priceRange;
      PaintCaches.paintText(
        canvas: canvas,
        paint: paint,
        key: 'mouse_position_right_text',
        text: price.toStringAsFixed(1),
        offset: Offset(
          size.width - KlineConfigs.rightTitlesWidth,
          data.mousePositionY,
        ),
        backgroundColor: Colors.black,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
    } else {
      /// 绘制右侧成交量
      final volumeHeight = size.height * KlineConfigs.volumeHeightRatio;
      if (data.mousePositionY > (size.height - volumeHeight)) {
        final valueRatio = 1 - (data.mousePositionY - size.height + volumeHeight) / volumeHeight;
        final volume = valueRatio * valueRange.maxVolume;
        PaintCaches.paintText(
          canvas: canvas,
          paint: paint,
          key: 'mouse_position_right_text',
          text: volume.toStringAsFixed(1),
          offset: Offset(
            size.width - KlineConfigs.rightTitlesWidth,
            data.mousePositionY,
          ),
          backgroundColor: Colors.black,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        );
      }
    }
  }
}
