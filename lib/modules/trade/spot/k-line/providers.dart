import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class KLineChartConfiguration extends _$KLineChartConfiguration {
  @override
  KLineChartConfigurationEntity build() {
    return const KLineChartConfigurationEntity();
  }

  void setInterval(String interval) {
    state = state.copyWith(interval: interval);
  }

  void setLimit(int limit) {
    state = state.copyWith(limit: limit);
  }

  void setOffset(double page) {
    final offset = (20 - page - 1) * state.limit;
    debugPrint('offset: $offset $page');
  }
}

final class KLineChartConfigurationEntity {
  const KLineChartConfigurationEntity({
    this.interval = '1m',
    this.limit = 100,
    this.offset = 0,
  });

  /// 分段数据的时间间隔
  final String interval;

  /// 应展示的最大数据量（图表缩放）
  final int limit;

  /// 数据偏移量（图表滚动）
  final int offset;

  final int initialPage = 20;

  KLineChartConfigurationEntity copyWith({
    String? interval,
    int? limit,
    int? offset,
  }) {
    return KLineChartConfigurationEntity(
      interval: interval ?? this.interval,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
