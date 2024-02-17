import 'package:flutter/material.dart';

/// K线图的绘制配置常量
class KlinePaintConfigs {
  /// 右侧标题宽度
  static const double rightTitlesWidth = 60;

  /// 底部标题高度
  static const double bottomTitlesHeight = 20;

  /// 价格区域高度比例
  static const double priceHeightRatio = 0.7;

  /// 成交量区域高度比例
  static const double volumeHeightRatio = 0.25;

  /// 价格区域和成交量区域之间的间隔高度比例
  static double get priceVolumeGapHeightRatio =>
      1 - priceHeightRatio - volumeHeightRatio;

  /// 价格区间分段数量
  static const int priceSegmentCount = 10;

  /// 成交量分段数量
  static const int volumeSegmentCount = 6;

  ///
  ///
  ///

  static void paintPriceVolumeDivider(Canvas canvas, Size size, Paint paint) {
    final y = size.height * priceHeightRatio;

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
}
