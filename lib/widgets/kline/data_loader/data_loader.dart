import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/data_loader/isolated_impl.dart';
import 'package:gateio_flutter/widgets/kline/data_loader/impl.dart';

const kDefaultCurrencyPair = 'BTC_USDT';
const kDefaultInterval = '1m';

/// K线数据加载器
/// 将数据加载和解析任务放到独立的 Isolate 中执行
/// 获取最新的1000条K线数据
/// 之后持续接收最新的K线数据
abstract class KlineDataLoader {
  KlineData get data;

  Stream<KlineData> get stream;

  /// 请求K线数据
  /// [offset] 请求的起始位置，0表示最新的数据
  /// [limit] 请求的数量
  /// [drawWidth] 绘制区域的宽度
  /// [drawHeight] 绘制区域的高度
  /// [scrollOffset] 滚动偏移量
  void request({
    required int offset,
    required int limit,
    required double drawWidth,
    required double drawHeight,
    required double scrollOffset,
  });

  KlineDataLoader();

  factory KlineDataLoader.auto() {
    if (kIsWeb) {
      return KlineDataLoaderImpl();
    } else {
      return IsolatedKLineLoaderImpl();
    }
  }

  void dispose();
}
