import 'dart:async';

import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/widgets/kline/calculator/calculator.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/data_loader/data_loader.dart';

class KlineDataLoaderImpl extends KlineDataLoader {
  KlineDataLoaderImpl() {
    _loadLast();
  }

  @override
  KlineData get data => _data;

  @override
  Stream<KlineData> get stream => _controller.stream;

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void request({
    required int offset,
    required int limit,
    required double drawWidth,
    required double drawHeight,
    required double scrollOffset,
  }) {
    calculateKlineData(offset: offset, limit: limit);
  }

  final _controller = StreamController<KlineData>.broadcast();
  var _kline = _TotalKlineData.empty();
  var _data = KlineData.empty();

  /// 根据需求和当前数据计算出需要显示的数据

  void calculateKlineData({required int offset, required int limit}) {
    // if (_kline.currencyPair != _data.currencyPair ||
    //     _kline.interval != _data.interval) {
    //   return;
    // }

    if (_kline.points.isEmpty || limit == 0) {
      _data = KlineData.builder(
        offset: offset,
        limit: limit,
        currencyPair: kDefaultCurrencyPair,
        interval: kDefaultInterval,
        points: [],
      );
      return;
    }

    final points = List<KlinePoint>.from(_kline.points);

    final end = points.length - offset;
    if (end < 0) {
      /// 请求的数据超出了当前数据的范围
      /// 加载更多旧数据
      _loadFirst();
    }

    _data = KlineData.builder(
      offset: offset,
      limit: limit,
      currencyPair: kDefaultCurrencyPair,
      interval: kDefaultInterval,
      points: calculateDisplayPoints(points, offset, limit),
    );
    _controller.add(_data);
  }

  // 加载最新的K线数据
  void _loadLast() async {
    final datas = await GateApi.spot.candlesticks(
      kDefaultCurrencyPair,
      interval: kDefaultInterval,
      limit: 1000,
    );

    _kline = _TotalKlineData(
      currencyPair: kDefaultCurrencyPair,
      interval: kDefaultCurrencyPair,
      points: datas.map((e) => KlinePoint.fromList(e)).toList(),
    );

    calculateKlineData(offset: _data.offset, limit: _data.limit);
  }

  // 加载更旧的K线数据
  void _loadFirst() async {
    //
  }
}

class _TotalKlineData {
  _TotalKlineData({
    required this.currencyPair,
    required this.interval,
    required this.points,
  });
  final String currencyPair;
  final String interval;
  final List<KlinePoint> points;

  factory _TotalKlineData.empty() {
    return _TotalKlineData(
      currencyPair: '',
      interval: '',
      points: [],
    );
  }
}
