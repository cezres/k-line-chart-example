import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/widgets/kline/calculator/calculator.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/data_loader/data_loader.dart';

class KlineDataLoaderImpl extends KlineDataLoader {
  KlineDataLoaderImpl() {
    loadLast();
  }

  @override
  KlineData get data => _data;

  @override
  Stream<KlineData> get stream => _controller.stream;

  @override
  void dispose() {}

  @override
  void request({
    required int offset,
    required int limit,
    required double drawWidth,
    required double drawHeight,
    required double scrollOffset,
  }) {
    _calculateKlineData(offset: offset, limit: limit);
  }

  final _controller = StreamController<KlineData>.broadcast();
  var _totalPoints = <KlinePoint>[];
  var _data = KlineData.empty();

  /// 根据需求和当前数据计算出需要显示的数据

  void _calculateKlineData({required int offset, required int limit}) {
    if (_totalPoints.isEmpty || limit == 0) {
      _data = KlineData.builder(
        offset: offset,
        limit: limit,
        currencyPair: kDefaultCurrencyPair,
        interval: kDefaultInterval,
        points: [],
      );
      return;
    }

    /// 加载更多旧数据
    if (_totalPoints.length - offset - limit < 500) {
      if (_totalPoints.length < 10000) {
        loadFirst();
      }
    }

    _data = KlineData.builder(
      offset: offset,
      limit: limit,
      currencyPair: kDefaultCurrencyPair,
      interval: kDefaultInterval,
      points: calculateDisplayPoints(_totalPoints, offset, limit),
    );
    _controller.add(_data);
  }

  // 加载最新的K线数据
  void loadLast() async {
    while (true) {
      try {
        if (_totalPoints.isEmpty) {
          final datas = await GateApi.spot.candlesticks(
            kDefaultCurrencyPair,
            interval: kDefaultInterval,
            limit: 1000,
          );
          appendLastPoints(datas);
          return;
        } else {
          /// 增量加载最新的数据
          final last = _totalPoints.last.timestamp;
          final datas = await GateApi.spot.candlesticks(
            kDefaultCurrencyPair,
            interval: kDefaultInterval,
            from: last,
          );
          appendLastPoints(datas);
        }
      } catch (e) {
        await Future.delayed(const Duration(seconds: 10));
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  bool _loadingFirst = false;

  // 加载更旧的K线数据
  void loadFirst() async {
    if (_loadingFirst || _totalPoints.isEmpty) {
      return;
    }
    _loadingFirst = true;
    debugPrint('loadFirst');

    try {
      final to = _totalPoints.first.timestamp - kDefaultIntervalValue;
      final from = to - kDefaultIntervalValue * 999;
      final datas = await GateApi.spot.candlesticks(
        kDefaultCurrencyPair,
        interval: kDefaultInterval,
        to: to,
        from: from,
      );
      appendFirstPoints(datas);

      _loadingFirst = false;
    } catch (e) {
      debugPrint('loadFirst error: $e');
      Future.delayed(const Duration(seconds: 10))
          .then((value) => _loadingFirst = false);
    }
  }

  void appendLastPoints(List<List<String>> datas) {
    if (datas.isEmpty) {
      return;
    }

    final points = datas.map((e) => KlinePoint.fromList(e)).toList();
    if (_totalPoints.isEmpty) {
      _totalPoints = points;
    } else {
      if (points.length == 1) {
        if (points.last.close == _totalPoints.last.close &&
            points.last.timestamp == _totalPoints.last.timestamp) {
          return;
        }
      }

      int index = _totalPoints.length;
      for (var i = _totalPoints.length - 1; i >= 0; i--) {
        if (_totalPoints[i].timestamp <= points.first.timestamp) {
          if (_totalPoints[i].timestamp == points.first.timestamp) {
            index = i;
            break;
          }
          break;
        }
      }
      if (index == _totalPoints.length) {
        _totalPoints = _totalPoints + points;
      } else {
        _totalPoints = _totalPoints.sublist(0, index) + points;
      }
    }

    _calculateKlineData(offset: _data.offset, limit: _data.limit);
  }

  void appendFirstPoints(List<List<String>> datas) {
    _totalPoints =
        datas.map((e) => KlinePoint.fromList(e)).toList() + _totalPoints;
  }
}
