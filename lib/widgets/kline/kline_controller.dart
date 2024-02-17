import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
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

    _loader.request(
      offset: _data.displayOffset,
      limit: _data.displayLimit,
      drawWidth: size.width,
      drawHeight: size.height,
      scrollOffset: _data.scrollOffset,
    );
  }

  void scroll(double scrollOffset) {
    if (scrollOffset != _data.scrollOffset) {
      final newData = _data.copyWithScrollOffset(scrollOffset);
      _request(
        newData.displayOffset,
        newData.displayLimit,
        _data.displayOffset,
        _data.displayLimit,
      );

      _data = newData;
      _streamController.add(_data);
    }
  }

  void setSegmentWidth(double width) {
    final newData = _data.copyWithSegmentWidth(width);
    _request(
      newData.displayOffset,
      newData.displayLimit,
      _data.displayOffset,
      _data.displayLimit,
    );
    _data = newData;
    _streamController.add(_data);
  }

  void resize(Size size) {
    final newData = _data.copyWithDrawSize(size.width, size.height);
    _request(
      newData.displayOffset,
      newData.displayLimit,
      _data.displayOffset,
      _data.displayLimit,
    );

    _data = newData;
    _streamController.add(_data);
  }

  void mouse(Offset position) {
    final newData = _data.copyWithMousePosition(position.dx, position.dy);
    _data = newData;
    _streamController.add(_data);
  }

  void refresh() {
    _loader.request(
      offset: max(_data.displayOffset, 0),
      limit: _data.displayLimit,
      drawWidth: _data.drawWidth,
      drawHeight: _data.drawHeight,
      scrollOffset: _data.scrollOffset,
    );
  }

  /// 请求数据
  /// 多请求少量数据，以减少数据加载频率
  void _request(int offset, int limit, int oldOffset, int oldLimit) {
    final int preload;
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      preload = 20;
    } else {
      preload = 6;
    }

    final offsetAbs = (offset - oldOffset).abs();
    final limitAbs = (limit - oldLimit).abs();
    if (offsetAbs < preload / 2 || limitAbs < preload / 2) {
      _loader.request(
        offset: max(offset - preload, 0),
        limit: limit + preload * 2,
        drawWidth: size.width,
        drawHeight: size.height,
        scrollOffset: _data.scrollOffset,
      );
    }
  }
}
