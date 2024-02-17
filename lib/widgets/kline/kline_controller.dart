import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gateio_flutter/widgets/kline/paint/kline_last_paint_data.dart';
import 'package:gateio_flutter/widgets/kline/paint/kline_paint_data.dart';
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

  KlinePaintData get data => _data;
  Stream<KlinePaintData> get stream => _streamController.stream;

  late KlinePaintData _data;
  final _streamController = StreamController<KlinePaintData>.broadcast();

  void dispose() {
    _loader.dispose();
  }

  void _initialize() {
    _data = KlinePaintData(
      kline: _loader.data,
      drawWidth: size.width,
      drawHeight: size.height,
      scrollOffset: 0,
      segmentWidth: 8,
      points: [],
      last: KlineLastPaintData(last: 0, y: 0),
    ).copyWithKlineData(_loader.data);

    _loader.stream.listen((event) {
      _data = _data.copyWithKlineData(event);
      _streamController.add(_data);
    });

    debugPrint('${_data.displayOffset} ${_data.displayLimit}');

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

      /// 降低数据加载频率
      final dataOffset = max(_data.displayOffset - 20, 0);
      if ((dataOffset - _data.kline.offset).abs() > 10) {
        _loader.request(
          offset: dataOffset,
          limit: newData.displayLimit + 40,
          drawWidth: size.width,
          drawHeight: size.height,
          scrollOffset: scrollOffset,
        );
      }
      _data = newData;
      _streamController.add(_data);
    }
  }
}
