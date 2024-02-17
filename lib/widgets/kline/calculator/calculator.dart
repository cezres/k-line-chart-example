import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gateio_flutter/utils/calculate_interval_of_numbers.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/paint/configuration.dart';

/// 计算一组K线点数据的最大价格、最小价格、最大成交量
KlinePointsValueRange calculateValueRangeWithKlinePoints(
    List<KlinePoint> points, double last) {
  if (points.isEmpty) {
    return const KlinePointsValueRange();
  }

  var maxPrice = last;
  var minPrice = last;
  var maxVolume = 0.0;
  for (var element in points) {
    if (maxPrice < element.high) {
      maxPrice = element.high;
    }
    if (minPrice > element.low) {
      minPrice = element.low;
    }
    if (maxVolume < element.baseVolume) {
      maxVolume = element.baseVolume.ceilToDouble();
    }
  }

  final priceInterval = calculateIntervalOfNumbers(
      maxPrice, minPrice, KlinePaintConfigs.priceSegmentCount, 10);
  // final volumeInterval = calculateIntervalOfNumbers(
  //     maxVolume, 0, KlinePaintConfigs.volumeSegmentCount, 60);
  // final maxVolume = maxVolume.ceilToDouble();
  final volumeInterval =
      ((maxVolume / KlinePaintConfigs.volumeSegmentCount) * 100)
              .ceilToDouble() /
          100;

  return KlinePointsValueRange(
    // maxPrice: maxPrice,
    // minPrice: minPrice,
    // priceRange: maxPrice - minPrice,
    // maxVolume: maxVolume,

    maxPrice: priceInterval.max,
    minPrice: priceInterval.min,
    priceRange: priceInterval.max - priceInterval.min,
    // maxVolume: volumeInterval.max,
    priceInterval: priceInterval.interval,
    // volumeInterval: volumeInterval.interval,
    maxVolume: maxVolume,
    volumeInterval: volumeInterval,
  );
}

/// 根据[offset]和[limit]计算出需要显示的K线数据点
List<KlinePoint> calculateDisplayPoints(
  List<KlinePoint> points,
  int offset,
  int limit,
) {
  /// K线点数据为空
  if (points.isEmpty) {
    return [];
  }

  /// 请求的数据超出了当前数据的范围
  if (offset > points.length) {
    return [];
  }

  final end = points.length - offset;
  final start = max(0, end - limit);
  try {
    return points.sublist(start, end);
  } catch (e) {
    debugPrint('calculateDisplayPoints: $e');
    rethrow;
  }
}

/// 根据K线分段宽度和滑动偏移量计算展示的数据偏移
int calculateDisplayPointsOffset(double segmentWidth, double scrollOffset) {
  return (scrollOffset / segmentWidth).floor();
}

// 根据K线分段宽度和画布宽度计算展示的数据量
int calculateDisplayPointsLimit(double segmentWidth, double drawWidth) {
  return (drawWidth / segmentWidth).ceil();
}
