import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'k_line_data_loader.g.dart';

/// K线数据加载器
/// 将数据加载和解析任务放到独立的 Isolate 中执行
@Riverpod(keepAlive: true)
Stream<KlineData> klineData(KlineDataRef ref) async* {
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _klineDataLoaderIsolateEntryPoint,
    receivePort.sendPort,
  );

  // TODO: compute

  // compute((message) => null, message)

  // ref.onDispose(() {
  //   isolate.kill(priority: Isolate.immediate);
  //   receivePort.close();
  //   ref.read(klineDataLoaderProvider.notifier).setup(null);
  // });

  /// 接收来自 Isolate 的消息
  await for (var element in receivePort) {
    if (element is KlineData) {
      yield element;
    } else if (element is SendPort) {
      ref.read(klineDataLoaderProvider.notifier).setup(element);
    }
  }
}

@Riverpod(keepAlive: true)
class KlineDataLoader extends _$KlineDataLoader {
  @override
  KlineDataLoaderState build() => KlineDataLoaderState();

  void setup(SendPort? sendPort) {
    if (sendPort != null) {
      if (state.range != null) {
        sendPort.send(state.range);
      }
    }
    state = KlineDataLoaderState(sendPort: sendPort);
  }

  /// 请求K线数据
  /// [offset] 请求的起始位置，0表示最新的数据
  /// [limit] 请求的数量
  void request(int offset, int limit) {
    final sendPort = state.sendPort;
    final range = KlinePointRange(offset: offset, limit: limit);
    if (sendPort != null) {
      sendPort.send(range);
    } else {
      state = KlineDataLoaderState(range: range);
    }
  }
}

class KlineDataLoaderState {
  KlineDataLoaderState({
    this.sendPort,
    this.range,
  });
  final SendPort? sendPort;
  final KlinePointRange? range;
}

final class KlineData {
  KlineData({
    required this.currencyPair,
    required this.interval,
    this.points = const [],
    this.last = 0,
    this.maxPrice = 0,
    this.minPrice = 0,
    this.maxVolume = 0,
    this.offset = 0,
  });

  final String currencyPair;
  final String interval;

  /// 以时间降序排列
  final List<KlinePoint> points;

  /// 最新的价格
  final double last;

  /// 当前数据集的最大价格
  final double maxPrice;

  /// 当前数据集的最小价格
  final double minPrice;

  /// 当前数据集的最大成交量
  final double maxVolume;

  /// 请求的起始位置，0表示最新的数据
  final int offset;
}

void _klineDataLoaderIsolateEntryPoint(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();
  // IsolateNameServer.registerPortWithName(
  //     receivePort.sendPort, 'KlineDataLoader');
  sendPort.send(receivePort.sendPort);

  final loader = _IsolatedKlineDataLoader(sendPort: sendPort);

  await for (var element in receivePort) {
    if (element is KlinePointRange) {
      loader.request(element);
    }
  }
}

final class _IsolatedKlineDataLoader {
  _IsolatedKlineDataLoader({required this.sendPort}) {
    _loader = _KlineTotalPointLoader(currencyPair: 'BTC_USDT', interval: '1m');
    _loader.stream.listen((event) {
      /// 检查数据更新的范围与请求的范围是否有交集
      _calculate();
    });
    _loader.reload();
  }

  final SendPort sendPort;
  late final _KlineTotalPointLoader _loader;

  var range = KlinePointRange(offset: 0, limit: 0);

  void request(KlinePointRange range) {
    this.range = range;
    _calculate();
  }

  void _calculate() {
    if (range.isEmpty) {
      return;
    }
    final points = _loader._points;
    if (points.isEmpty) {
      return;
    }

    final offset = range.offset;
    final limit = range.limit;

    final end = points.length - offset;
    if (end < 0) {
      /// 请求的数据超出了当前数据的范围
      sendPort.send(KlineData(
        currencyPair: _loader.currencyPair,
        interval: _loader.interval,
      ));

      /// 加载更多旧数据
      _loader.loadFirst();
      return;
    }

    final start = max(0, end - limit);
    final displayPoints = _loader._points.sublist(start, end).reversed.toList();

    var maxPrice = 0.0;
    var minPrice = double.infinity;
    var maxVolume = 0.0;
    for (var element in displayPoints) {
      if (maxPrice < element.high) {
        maxPrice = element.high;
      }
      if (minPrice > element.low) {
        minPrice = element.low;
      }
      if (maxVolume < element.baseVolume) {
        maxVolume = element.baseVolume;
      }
    }

    final data = KlineData(
      currencyPair: _loader.currencyPair,
      interval: _loader.interval,
      points: displayPoints,
      last: points.last.close,
      maxPrice: maxPrice,
      minPrice: minPrice,
      maxVolume: maxVolume,
      offset: offset,
    );
    sendPort.send(data);
  }
}

/// K线数据加载器
/// 获取最新的1000条K线数据
/// 之后持续接收最新的K线数据
final class _KlineTotalPointLoader {
  _KlineTotalPointLoader({
    required this.currencyPair,
    required this.interval,
  });

  final String currencyPair;
  final String interval;

  Stream<KlinePointRange> get stream => _controller.stream;

  List<KlinePoint> _points = [];
  final _controller = StreamController<KlinePointRange>.broadcast();

  void reload() async {
    final datas = await GateApi.spot.candlesticks(
      currencyPair,
      interval: interval,
      limit: 1000,
    );
    _points = datas.map((e) => KlinePoint.fromList(e)).toList();
    _controller.sink.add(KlinePointRange(offset: 0, limit: datas.length));
  }

  /// 加载最新的K线数据
  void _loadLast() {
    //
  }

  /// 加载更旧的K线数据
  void loadFirst() async {
    //
  }
}

/// K线数据
final class KlinePoint {
  KlinePoint({
    required this.timestamp,
    required this.quoteVolume,
    required this.close,
    required this.high,
    required this.low,
    required this.open,
    required this.baseVolume,
    required this.isClose,
  });

  /// 时间戳
  final int timestamp;

  /// 成交量
  final double quoteVolume;

  /// 收盘价
  final double close;

  /// 最高价
  final double high;

  /// 最低价
  final double low;

  /// 开盘价
  final double open;

  /// 成交额
  final double baseVolume;

  /// 是否是收盘数据
  final bool isClose;

  factory KlinePoint.fromList(List<String> list) => KlinePoint(
        timestamp: int.parse(list[0]),
        quoteVolume: double.parse(list[1]),
        close: double.parse(list[2]),
        high: double.parse(list[3]),
        low: double.parse(list[4]),
        open: double.parse(list[5]),
        baseVolume: double.parse(list[6]),
        isClose: bool.parse(list[7]),
      );
}

/// K线数据范围
final class KlinePointRange {
  KlinePointRange({required this.offset, required this.limit});

  /// 起始位置，0表示最新的数据
  final int offset;

  /// 数量
  final int limit;

  /// 判断是否与另一个 KlinePointRange 对象有交集
  bool hasIntersection(KlinePointRange other) {
    final int end = offset + limit;
    final int otherEnd = other.offset + other.limit;

    // 判断一个范围的起始位置是否在另一个范围之内
    bool isStartInside = (other.offset >= offset && other.offset < end) ||
        (offset >= other.offset && offset < otherEnd);

    // 特殊情况处理：当 offset 为 0 时，需要特别判断
    if (offset == 0 || other.offset == 0) {
      // 一个范围的 offset 为 0 时，它表示最新的数据，可能与任何范围有交集
      return true;
    }

    return isStartInside;
  }

  bool get isEmpty => limit == 0;

  bool get isNotEmpty => limit > 0;
}
