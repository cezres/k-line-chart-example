import 'dart:isolate';

import 'package:gateio_flutter/widgets/kline/calculator/calculator.dart';

final class KlineData {
  KlineData({
    required this.offset,
    required this.limit,
    required this.currencyPair,
    required this.interval,
    required this.points,
    required this.last,
    required this.valueRange,
  });

  factory KlineData.empty() {
    return KlineData(
      offset: 0,
      limit: 0,
      currencyPair: '',
      interval: '',
      points: [],
      last: 0,
      valueRange: const KlinePointsValueRange(),
    );
  }

  factory KlineData.builder({
    required int offset,
    required int limit,
    required String currencyPair,
    required String interval,
    required List<KlinePoint> points,
  }) {
    final last = points.isEmpty ? 0.0 : points.last.close;
    return KlineData(
      offset: offset,
      limit: limit,
      currencyPair: currencyPair,
      interval: interval,
      points: points,
      last: last,
      valueRange: KlinePointsValueRange.builder(points, last),
    );
  }

  /// 请求的起始位置，0表示最新的数据
  final int offset;
  final int limit;

  final String currencyPair;
  final String interval;

  /// 以时间降序排列
  final List<KlinePoint> points;

  /// 最新的价格
  final double last;

  /// K线数据的值范围
  final KlinePointsValueRange valueRange;
}

/// K线数据
final class KlinePoint {
  KlinePoint({
    required this.timestamp,
    required this.quoteVolume,
    required this.close,
    required this.high,
    required this.low,
    required this.open,
    required this.baseVolume,
    required this.isClose,
  });

  /// 时间戳
  final int timestamp;

  /// 成交量
  final double quoteVolume;

  /// 收盘价
  final double close;

  /// 最高价
  final double high;

  /// 最低价
  final double low;

  /// 开盘价
  final double open;

  /// 成交额
  final double baseVolume;

  /// 是否是收盘数据
  final bool isClose;

  factory KlinePoint.fromList(List<String> list) => KlinePoint(
        timestamp: int.parse(list[0]),
        quoteVolume: double.parse(list[1]),
        close: double.parse(list[2]),
        high: double.parse(list[3]),
        low: double.parse(list[4]),
        open: double.parse(list[5]),
        baseVolume: double.parse(list[6]),
        isClose: bool.parse(list[7]),
      );
}

final class KlinePointsValueRange {
  const KlinePointsValueRange({
    this.maxPrice = 0,
    this.minPrice = 0,
    this.priceRange = 0,
    this.maxVolume = 0,
    this.priceInterval = 0,
    this.volumeInterval = 0,
  });
  final double maxPrice; // TODO: remove this
  final double minPrice;
  final double priceRange;
  final double maxVolume;
  final double priceInterval;
  final double volumeInterval;

  factory KlinePointsValueRange.builder(List<KlinePoint> points, double last) =>
      calculateValueRangeWithKlinePoints(points, last);
}

/// K线数据范围
final class KlinePointRange {
  KlinePointRange({required this.offset, required this.limit});

  /// 起始位置，0表示最新的数据
  final int offset;

  /// 数量
  final int limit;

  /// 判断是否与另一个 KlinePointRange 对象有交集
  bool hasIntersection(KlinePointRange other) {
    final int end = offset + limit;
    final int otherEnd = other.offset + other.limit;

    // 判断一个范围的起始位置是否在另一个范围之内
    bool isStartInside = (other.offset >= offset && other.offset < end) ||
        (offset >= other.offset && offset < otherEnd);

    // 特殊情况处理：当 offset 为 0 时，需要特别判断
    if (offset == 0 || other.offset == 0) {
      // 一个范围的 offset 为 0 时，它表示最新的数据，可能与任何范围有交集
      return true;
    }

    return isStartInside;
  }

  bool get isEmpty => limit == 0;

  bool get isNotEmpty => limit > 0;
}

/// TODO: 使用 TransferableTypedData 传输数据以避免复制提高性能
class KlineDataEncoder {
  static TransferableTypedData encode() {
    return TransferableTypedData.fromList([]);
  }
}

class KlineDataDecoder {
  KlineDataDecoder(this.data);
  final TransferableTypedData data;
}
