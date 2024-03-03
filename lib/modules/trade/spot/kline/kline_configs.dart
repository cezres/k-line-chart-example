import 'package:flutter/material.dart';

/// K线图的绘制配置常量
class KlineConfigs {
  /// 右侧标题宽度
  static const double rightTitlesWidth = 60;

  /// 底部标题高度
  static const double bottomTitlesHeight = 20;

  /// 价格区域高度比例
  static const double priceHeightRatio = 0.7;

  /// 成交量区域高度比例
  static const double volumeHeightRatio = 0.25;

  /// 价格区域和成交量区域之间的间隔高度比例
  static double get priceVolumeGapHeightRatio => 1 - priceHeightRatio - volumeHeightRatio;

  /// 价格区间分段数量
  static const int priceSegmentCount = 10;

  /// 成交量分段数量
  static const int volumeSegmentCount = 6;

  /// 允许右侧滚动超出的的距离
  static const double rightScrollOffset = 200;

  /// 允许缩放的最小分段宽度
  static const double minScaleSegmentWidth = 2;

  /// 允许缩放的最大分段宽度
  static const double maxScaleSegmentWidth = 20;

  static const Color riseColor = Color.fromARGB(255, 242, 73, 94);
  static const Color fallColor = Color.fromARGB(255, 16, 173, 122);

  static const Color volumeRiseColor = Color.fromARGB(255, 248, 163, 173);
  static const Color volumeFallColor = Color.fromARGB(255, 135, 213, 188);

  ///
  ///
  ///

  static void paintPriceVolumeDivider(Canvas canvas, Size size, Paint paint) {
    final y = size.height * (priceHeightRatio + (1 - priceHeightRatio - volumeHeightRatio) / 2);

    paint.color = Colors.grey[300]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
}

class PaintCaches {
  static final Map<String, dynamic> values = {};
  static final Map<String, dynamic> caches = {};

  static T putIfAbsent<T, V>(String key, V value, T Function() ifAbsent) {
    if (values[key] == value) {
      // debugPrint('hit cache: $key');
      return caches[key] as T;
    }
    final result = ifAbsent();
    values[key] = value;
    caches[key] = result;
    return result;
  }

  static Rect paintText({
    required Canvas canvas,
    required Paint paint,
    required String key,
    required String text,
    required Offset offset,
    TextStyle style = const TextStyle(color: Colors.black, fontSize: 12),
    Color? backgroundColor,
    Radius? backgroundRadius,
  }) {
    final textPainter = putIfAbsent(key, text, () {
      final textSpan = TextSpan(text: text, style: style);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: 400);
      return textPainter;
    });

    final textOffset = Offset(offset.dx, offset.dy - textPainter.height / 2);
    final rect = Rect.fromLTWH(
      textOffset.dx - 4,
      textOffset.dy - 4,
      textPainter.width + 8,
      textPainter.height + 8,
    );

    if (backgroundColor != null) {
      paint.color = backgroundColor;
      paint.style = PaintingStyle.fill;

      if (backgroundRadius != null) {
        final rrect = RRect.fromRectAndRadius(rect, backgroundRadius);
        canvas.drawRRect(rrect, paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    }

    textPainter.paint(canvas, textOffset);

    return rect;
  }

  static void setupHorizontalDottedLinePath({
    required Path path,
    required double start,
    required double end,
    required double y,
    double dashWidth = 2.0,
    double dashSpace = 2.0,
  }) {
    double startX = start;
    while (startX < end) {
      path.moveTo(startX, y);
      path.lineTo(startX + dashWidth, y);

      startX += dashWidth + dashSpace;
    }
  }

  static void setupVerticalDottedLinePath({
    required Path path,
    required double start,
    required double end,
    required double x,
    double dashWidth = 2.0,
    double dashSpace = 2.0,
  }) {
    double startY = start;
    while (startY < end) {
      path.moveTo(x, startY);
      path.lineTo(x, startY + dashWidth);

      startY += dashWidth + dashSpace;
    }
  }
}
