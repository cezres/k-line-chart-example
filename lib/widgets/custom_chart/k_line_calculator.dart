import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/k-line/chart_data_loader.dart';
import 'package:gateio_flutter/utils/merge_sorted_arrays.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_calculator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'k_line_calculator.g.dart';

@Riverpod(keepAlive: true)
class KLineCalculator extends _$KLineCalculator {
  @override
  KLineCalculatorState build() {
    ref.onDispose(state.dispose);
    return KLineCalculatorState();
  }
}

final class KLineCalculatorState {
  final ReceivePort receivePort = ReceivePort();

  KLineCalculatorState() {
    compute(
      _kLineCalculatorIsolateEntryPoint,
      IsolatedKLineCalculatorInitializer(sendPort: receivePort.sendPort),
    );
  }

  void dispose() {
    receivePort.close();
  }
}

void _kLineCalculatorIsolateEntryPoint(
  IsolatedKLineCalculatorInitializer initializer,
) {
  final kLineCalculator = KLineCalculator();
  kLineCalculator.build();
}

final class IsolatedKLineCalculatorInitializer {
  IsolatedKLineCalculatorInitializer({required this.sendPort});
  final SendPort sendPort;
  final String currencyPair = 'BTC_USDT';
}

final class IsolatedKLineCalculator {
  final ReceivePort receivePort = ReceivePort();
  final IsolatedKLineCalculatorInitializer initializer;

  /// K线数据源
  final _dataSource = _KLineDataSource();

  /// 画布的尺寸
  Size canvasSize = Size.zero;

  /// 滚动的偏移量
  double scrollOffset = 0;

  IsolatedKLineCalculator(this.initializer) {
    initializer.sendPort.send(receivePort.sendPort);

    _dataSource.stream.listen((event) {
      //
    });
  }

  void dispose() {
    _dataSource.dispose();
    receivePort.close();
  }
}

final class _KLineDataSource {
  _KLineDataSource();

  List<CustomChartGroupData> groups = [];
  Stream<void> get stream => _controller.stream;

  final _controller = StreamController();
  String _currencyPair = '';
  bool _isDisposed = false;

  void run(String currencyPair) {
    _currencyPair = currencyPair;

    Future.microtask(() async {
      while (!_isDisposed) {
        try {
          final newGroups = await _fetchDatasFromOldDatas(
            groups,
            currencyPair: _currencyPair,
            interval: '1m',
          );
          groups = mergeSortedArrays(newGroups, groups);
          _controller.sink.add(null);
        } catch (e) {
          debugPrint('IsolatedKLineCalculator error: $e');
        }
        await Future.delayed(const Duration(seconds: 4));
      }
    });
  }

  Future<List<CustomChartGroupData>> _fetchDatasFromOldDatas(
      List<CustomChartGroupData> datas,
      {required String currencyPair,
      required String interval}) async {
    final List<List<String>> newDatas;
    if (datas.isNotEmpty) {
      final last = datas.last.object;

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

    return newDatas
        .map(
          (e) => CustomChartGroupData.fromData(ChartDataEntity(interval, e)),
        )
        .toList();
  }

  void dispose() {
    groups.clear();
    _isDisposed = true;
  }
}
