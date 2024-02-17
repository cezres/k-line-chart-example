import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/k-line/chart_data_loader.dart';
import 'package:gateio_flutter/utils/merge_sorted_arrays.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_calculator.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'k_line_calculator.g.dart';

@Riverpod(keepAlive: true)
class KLineCalculator extends _$KLineCalculator {
  @override
  KLineCalculatorState build() {
    final state = KLineCalculatorState();

    final subscription = ref.listen(
        customChartGestureDetectorProvider.select((value) => value.offset),
        (previous, next) {
      debugPrint('xxx - offset: $next');
      state.setOffset(next);
    });

    ref.onDispose(() {
      state.dispose();
      subscription.close();
    });

    return state;
  }
}

final class KLineCalculatorState {
  final _receivePort = ReceivePort();

  Stream<CustomChartData> get stream => _streamController.stream;
  final _streamController = StreamController<CustomChartData>();

  SendPort? _sendPort;
  final _ready = Completer<void>();

  double width = 0;
  double height = 0;

  double offset = 0;

  KLineCalculatorState() {
    compute(
      _kLineCalculatorIsolateEntryPoint,
      IsolatedKLineCalculatorInitializer(sendPort: _receivePort.sendPort),
    );

    _receivePort.listen((message) {
      if (message is CustomChartData) {
        _streamController.sink.add(message);
      } else if (message is SendPort) {
        _sendPort = message;
        _ready.complete();
        message.send([width, height]);
      }
    });
  }

  void dispose() {
    _receivePort.close();
  }

  void setSize(double width, double height) {
    if (width == 0 || height == 0) {
      return;
    }
    if (width == this.width && height == this.height) {
      return;
    }
    _sendPort?.send([width, height]);
  }

  void setOffset(double offset) {
    if (offset == this.offset) {
      return;
    }
    this.offset = offset;
    _sendPort?.send(offset);
  }
}

void _kLineCalculatorIsolateEntryPoint(
  IsolatedKLineCalculatorInitializer initializer,
) async {
  final receivePort = ReceivePort();
  initializer.sendPort.send(receivePort.sendPort);
  final calculator = IsolatedKLineCalculator(initializer.sendPort);
  await for (var element in receivePort) {
    if (element is List<double>) {
      calculator.canvasWidth = element[0];
      calculator.canvasHeight = element[1];
      calculator._calculateDisplayGroups();
    } else if (element is double) {
      calculator.scrollOffset = element;
      calculator._calculateDisplayGroups();
    } else if (element == 0) {
      calculator.dispose();
      break;
    }
  }
  debugPrint('IsolatedKLineCalculator disposed');
}

final class IsolatedKLineCalculatorInitializer {
  IsolatedKLineCalculatorInitializer({required this.sendPort});
  final SendPort sendPort;
  final String currencyPair = 'BTC_USDT';
}

final class IsolatedKLineCalculator {
  final SendPort sendPort;

  /// K线数据源
  final _dataSource = _KLineDataSource();

  /// 画布的尺寸
  double canvasWidth = 0;
  double canvasHeight = 0;

  /// 向左滚动的距离
  double scrollOffset = 0;

  List<CustomChartGroupData> _displayGroups = [];
  double _maxDisplayPrice = 0;
  double _minDisplayPrice = 0;
  double _maxDisplayVolume = 0;
  double _maxDisplayTimestamp = 0;
  double _minDisplayTimestamp = 0;
  double _drawOffset = 0;
  int? _distanceIndex;

  final List<KLinePointChartData> points = [];
  KLineLastChartData? last;

  IsolatedKLineCalculator(this.sendPort) {
    final weak = WeakReference(this);
    _dataSource.run('BTC_USDT');
    _dataSource.stream.listen((event) {
      weak.target?._calculateDisplayGroups();
    });
  }

  void dispose() {
    _dataSource.dispose();
  }

  /// 计算需要展示的数据和绘制的偏移量
  void _calculateDisplayGroups() {
    if (_dataSource.groups.isEmpty || canvasWidth == 0) {
      return;
    }

    final groups = _dataSource.groups;

    /// 根据缩放和滚动偏移计算需要展示的数据，以及绘制的偏移量
    const displayLimit = 100;
    final segmentWidth = canvasWidth / displayLimit;
    final distance = scrollOffset / segmentWidth;
    final distanceIndex = distance.floor();
    _drawOffset = (distance - distanceIndex) * segmentWidth;
    // debugPrint('distance: $distance');

    if (_distanceIndex == distanceIndex) {
      /// 滑动变化较小时无需重新计算需要显示的数据
      /// 仅需要更新绘图偏移量
      rebuildChartData();
    } else {
      _distanceIndex = distanceIndex;
      final displayStart = max(0, groups.length - displayLimit - distanceIndex);
      final displayEnd = displayStart + displayLimit;
      // debugPrint("Start: $displayStart");
      _displayGroups = groups.sublist(displayStart, displayEnd);

      _calculateDisplayValueRange();

      _calculateDisplayPoints(displayStart);

      rebuildChartData();
    }
  }

  void _calculateDisplayPoints(int start) {
    points.clear();

    final last = _dataSource.groups.last.object.close;
    final maxPrice = max(_maxDisplayPrice, last);
    final minPrice = min(_minDisplayPrice, last);
    final priceRange = maxPrice - minPrice;

    final maxVolume = _maxDisplayVolume;

    final double priceHeight = canvasHeight * 0.7;
    final double priceBaseY = canvasHeight * 0.3;
    final double priceYScale = priceHeight / priceRange;

    final double volumeHeight = canvasHeight * 0.25;
    final double volumeYScale = volumeHeight / maxVolume;

    for (var element in _displayGroups) {
      points.add(KLinePointChartData(
        volume: KLineVolumeChartDate(
          volume: element.object.baseVolume,
          maxY: canvasHeight - element.object.baseVolume * volumeYScale,
        ),
        isUp: element.object.close > element.object.open,
        distance: _dataSource.groups.length - start - 1,
      ));
    }

    this.last = KLineLastChartData(
      last: _dataSource.groups.last.object.close,
      y: canvasHeight - ((last - minPrice) * priceYScale + priceBaseY),
    );
  }

  /// 计算展示数据的最大最小值
  void _calculateDisplayValueRange() {
    if (_displayGroups.isEmpty) {
      return;
    }

    final groups = _displayGroups;
    _maxDisplayTimestamp = groups.last.x;
    _minDisplayTimestamp = groups.first.x;
    _maxDisplayPrice = groups.first.object.high;
    _minDisplayPrice = groups.first.object.low;
    _maxDisplayVolume = groups.first.object.baseVolume;

    for (var group in groups) {
      if (group.object.high > _maxDisplayPrice) {
        _maxDisplayPrice = group.object.high;
      }
      if (group.object.low < _minDisplayPrice) {
        _minDisplayPrice = group.object.low;
      }
      if (group.object.baseVolume > _maxDisplayVolume) {
        _maxDisplayVolume = group.object.baseVolume;
      }
    }
    //
  }

  void rebuildChartData() {
    // 计算显示的数据
    sendPort.send(CustomChartData(
      displayGroups: _displayGroups,
      maxDisplayPrice: _maxDisplayPrice,
      minDisplayPrice: _minDisplayPrice,
      maxDisplayVolume: _maxDisplayVolume,
      maxDisplayX: _maxDisplayTimestamp,
      minDisplayX: _minDisplayTimestamp,
      drawOffset: _drawOffset,
      lastPrice: _dataSource.groups.last.object.close,
      last: last ?? KLineLastChartData(last: 0, y: 0),
      points: points,
    ));
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
          return;
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
