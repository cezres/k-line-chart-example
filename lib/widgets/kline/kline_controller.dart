import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/painter/kline_draw_data.dart';
import 'package:gateio_flutter/widgets/kline/data_loader/data_loader.dart';

class KlineController {
  KlineController({
    required this.currencyPair,
    required this.interval,
    required this.size,
  }) {
    _initialize();
  }

  final String currencyPair;
  final String interval;
  final Size size;

  final KlineDataLoader _loader = KlineDataLoader.auto();

  KlineDrawData get data => _data;
  Stream<KlineDrawData> get stream => _streamController.stream;

  late KlineDrawData _data;
  final _streamController = StreamController<KlineDrawData>.broadcast();

  void dispose() {
    _loader.dispose();
  }

  void _initialize() {
    _data = KlineDrawData(
      kline: _loader.data,
      drawWidth: size.width,
      drawHeight: size.height,
      scrollOffset: 0,
      segmentWidth: 6,
      points: [],
      last: KlineLastDrawData(last: 0, y: 0),
    ).copyWithKlineData(_loader.data);

    _loader.stream.listen((event) {
      _data = _data.copyWithKlineData(event);
      _streamController.add(_data);
    });

    debugPrint('${_data.displayOffset} ${_data.displayLimit}');

    /// TODO: 应当加载1.5倍的数据量
    /// 当滚动到末尾时，再重新加载，以减小滑动时部分数据的计算频率

    _loader.request(
      offset: _data.displayOffset,
      limit: _data.displayLimit,
      drawWidth: size.width,
      drawHeight: size.height,
      scrollOffset: _data.scrollOffset,
    );
  }

  bool willScroll(double offset) {
    if (offset < -200) {
      return false;
    }
    return true;
  }

  void scroll(double scrollOffset) {
    if (scrollOffset != _data.scrollOffset) {
      final newData = _data.copyWithScrollOffset(scrollOffset);
      final dataOffset = max(_data.displayOffset, 0);
      if (dataOffset != _data.kline.offset) {
        _loader.request(
          offset: dataOffset,
          limit: newData.displayLimit,
          drawWidth: size.width,
          drawHeight: size.height,
          scrollOffset: scrollOffset,
        );
      }
      _data = newData;
      _streamController.add(_data);
    }
  }

  void requestMoreData() {
    //
  }
}

class KlinePaintData {
  const KlinePaintData({
    required this.kline,
    required this.scrollOffset,
  });

  final KlineData kline;
  final double scrollOffset;

  KlinePaintData copyWith({
    KlineData? kline,
    double? scrollOffset,
  }) {
    return KlinePaintData(
      kline: kline ?? this.kline,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }
}
