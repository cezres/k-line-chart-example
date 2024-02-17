import 'dart:math';

/// 计算数值区间
IntervalOfNumbers calculateIntervalOfNumbers(
    double max, double min, int segmentCount,
    [int x = 10]) {
  var interval = (max - min) / segmentCount;
  var exponent = 0;
  while (interval > x) {
    interval /= x;
    exponent++;
  }
  interval = interval.roundToDouble() * pow(x, exponent);

  return IntervalOfNumbers(
    interval: interval,
    max: ((max / interval).floorToDouble() + 1) * interval,
    min: (min / interval).floorToDouble() * interval,
  );
}

final class IntervalOfNumbers {
  const IntervalOfNumbers({
    required this.interval,
    required this.max,
    required this.min,
  });

  final double interval;
  final double max;
  final double min;

  @override
  String toString() {
    return '{interval: $interval, max: $max, min: $min}';
  }
}
