import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/data/kline_data.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/data_loader/data_loader.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/data_loader/impl.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_last_paint_data.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/painter/kline_paint_data.dart';

class IsolatedKLineLoaderImpl extends KlineDataLoader {
  IsolatedKLineLoaderImpl() {
    compute(
      _klineDataLoaderIsolateEntryPoint,
      _receivePort.sendPort,
    );

    _subscription = _receivePort.listen((message) {
      if (message is KlinePaintData) {
        _data = message;
        _controller.add(message);
      } else if (message is SendPort) {
        _sendPort = message;
        if (_cache != null) {
          message.send(_cache);
        }
      }
    });
  }

  final _receivePort = ReceivePort();
  SendPort? _sendPort;
  late final StreamSubscription _subscription;
  final _controller = StreamController<KlinePaintData>.broadcast();
  KlinePaintData _data = KlinePaintData(
    kline: KlineData.empty(),
    drawWidth: 0,
    drawHeight: 0,
    scrollOffset: 0,
    segmentWidth: 8,
    points: [],
    last: KlineLastPaintData(last: 0, y: 0, isRise: false),
  );

  @override
  Stream<KlinePaintData> get stream => _controller.stream;

  @override
  KlinePaintData get data => _data;

  List? _cache;

  @override
  void request({
    required int offset,
    required int limit,
    required double drawWidth,
    required double drawHeight,
    required double scrollOffset,
    required double segmentWidth,
  }) {
    final sendPort = _sendPort;
    if (sendPort != null) {
      sendPort.send([offset, limit, drawWidth, drawHeight, scrollOffset, segmentWidth]);
    } else {
      _cache = [offset, limit, drawWidth, drawHeight, scrollOffset, segmentWidth];
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _receivePort.close();
  }
}

void _klineDataLoaderIsolateEntryPoint(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  final loader = KlineDataLoaderImpl();
  loader.stream.listen((event) {
    sendPort.send(event);
  });

  await for (var element in receivePort) {
    if (element is List) {
      loader.request(
        offset: element[0],
        limit: element[1],
        drawWidth: element[2],
        drawHeight: element[3],
        scrollOffset: element[4],
        segmentWidth: element[5],
      );
    }
  }
}
