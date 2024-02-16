import 'package:flutter/material.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/providers.dart';
import 'package:gateio_flutter/modules/trade/spot/k-line/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chart_data_loader.g.dart';

@Riverpod(keepAlive: true)
class ChartDataLoader extends _$ChartDataLoader {
  @override
  Stream<ChartDataLoadedEntity> build() async* {
    final currencyPair =
        ref.watch(currentCurrencyPairProvider.select((value) => value?.id));
    if (currencyPair == null) {
      return;
    }

    final configuration = ref.watch(kLineChartConfigurationProvider);
    final interval = configuration.interval;

    /// TODO: 从缓存加载有效数据
    var entity = ChartDataLoadedEntity(interval: interval);
    yield entity;

    bool isDisposed = false;
    ref.onDispose(() => isDisposed = true);

    while (!isDisposed) {
      try {
        final datas = await _fetchDatasFromOldDatas(
          entity.datas,
          currencyPair: currencyPair,
          interval: interval,
        );

        entity = entity.appendNewDatas(datas);
        yield entity;
        return;
      } catch (e) {
        debugPrint('Error: $e');
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  Future<List<ChartDataEntity>> _fetchDatasFromOldDatas(
      List<ChartDataEntity> datas,
      {required String currencyPair,
      required String interval}) async {
    final List<List<String>> newDatas;
    if (datas.isNotEmpty) {
      final last = datas.last;

      /// TODO: 检查时间戳，如果大于100个时间间隔，那么直接获取最新数据

      /// 如果第一个数据是关闭的，那么从下一个时间开始获取
      if (last.isClose) {
        newDatas = await GateApi.spot.candlesticks(
          currencyPair,
          interval: interval,
          from: last.timestamp + 1,
        );
      } else {
        newDatas = await GateApi.spot.candlesticks(
          currencyPair,
          interval: interval,
          from: last.timestamp,
        );
      }
    } else {
      newDatas = await GateApi.spot.candlesticks(
        currencyPair,
        interval: interval,
        limit: 1000,
      );
    }

    return newDatas.map((e) => ChartDataEntity(interval, e)).toList();
  }
}

final class ChartDataLoadedEntity {
  const ChartDataLoadedEntity({
    required this.interval,
    this.datas = const [],
    this.maxPrice = 0,
    this.minPrice = double.infinity,
    this.maxVolume = 0,
    this.minVolume = double.infinity,
  });
  final String interval;
  final List<ChartDataEntity> datas;

  final double maxPrice;
  final double minPrice;
  final double maxVolume;
  final double minVolume;

  ChartDataLoadedEntity appendNewDatas(List<ChartDataEntity> datas) {
    var newMaxPrice = maxPrice;
    var newMinPrice = minPrice;
    var newMaxVolume = maxVolume;
    var newMinVolume = minVolume;

    /// 更新最大最小价格和最大成交量
    for (var element in datas) {
      if (element.high > newMaxPrice) {
        newMaxPrice = element.high;
      }
      if (element.low < newMinPrice) {
        newMinPrice = element.low;
      }
      if (element.baseVolume > newMaxVolume) {
        newMaxVolume = element.baseVolume;
      }
      if (element.baseVolume < newMinVolume) {
        newMinVolume = element.baseVolume;
      }
    }

    if (this.datas.isNotEmpty && !this.datas.last.isClose) {
      /// 如果最后一个数据是未关闭的，那么删除最后一个数据
      this.datas.removeLast();
    }

    return ChartDataLoadedEntity(
      interval: interval,

      /// 合并两个正序并且数据连续的数组
      datas: mergeSortedArrays(datas, this.datas),

      maxPrice: newMaxPrice,
      minPrice: newMinPrice,
      maxVolume: newMaxVolume,
      minVolume: newMinVolume,
    );
  }

  /// 合并两个数据集
  /// 优先保留[list1]的数据
  /// [list1] 必须是有序且数据连续的数据集
  /// [list2] 必须是有序的数据集
  static List<T> mergeSortedArrays<T extends Comparable>(
      List<T> list1, List<T> list2) {
    if (list1.isEmpty) {
      return list2;
    }

    /// list2中比list1大的数据
    final larger = <T>[];

    /// list2中比list1小的数据
    final smaller = <T>[];

    for (var element in list2) {
      if (element.compareTo(list1.first) > 0) {
        larger.add(element);
      } else if (element.compareTo(list1.last) < 0) {
        smaller.add(element);
      }
    }

    return [
      // 比list2小的数据
      ...smaller,
      // list1
      ...list1,
      // 比list1大的数据
      ...larger,
    ];
  }
}

class ChartDataEntity implements Comparable<ChartDataEntity> {
  ChartDataEntity(this.interval, List<String> values)
      : timestamp = int.parse(values[0]),
        quoteVolume = double.parse(values[1]),
        close = double.parse(values[2]),
        high = double.parse(values[3]),
        low = double.parse(values[4]),
        open = double.parse(values[5]),
        baseVolume = double.parse(values[6]),
        isClose = bool.parse(values[7]);

  final String interval;

  final int timestamp;
  final double open;
  final double close;
  final double high;
  final double low;
  final double quoteVolume;
  final double baseVolume;
  final bool isClose;

  @override
  int compareTo(ChartDataEntity other) {
    return timestamp.compareTo(other.timestamp);
  }
}
