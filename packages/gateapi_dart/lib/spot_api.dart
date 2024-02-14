import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateapi_dart/impls/api_client.dart';
import 'package:gateapi_dart/types/order_book.dart';

/// 现货交易
abstract class SpotApi extends ApiClient {
  /// 查询支持的所有交易对
  Future<List<CurrencyPair>> currencyPairs();

  /// 获取交易对 ticker 信息
  /// 如果指定 [currencyPair] 则只查询该交易对，否则返回全部信息
  /// [timezone] 时区
  Future<List<Ticker>> tickers(String? currencyPair,
      {Timezone timezone = Timezone.utc8});

  /// 获取市场深度信息
  /// 市场深度买单会按照价格从高到低排序，卖单反之
  /// [currencyPair] 交易对
  /// [interval] 合并深度指定的价格精度，0 为不合并，不指定则默认为 0
  /// [limit] 深度档位数量
  /// [withId] 是否返回深度更新 ID
  Future<OrderBook> orderBook(String currencyPair,
      {String? interval, int? limit, bool? withId});

  /// 获取交易对的 K 线数据
  /// [currencyPair] 交易对
  /// [limit] 指定数据点的数量，适用于取最近 limit 数量的数据，该字段与 from, to 互斥，如果指定了 from, to 中的任意字段，该字段会被拒绝
  /// [from] 指定 K 线图的起始时间，注意时间格式为秒(s)精度的 Unix 时间戳，不指定则默认为 to - 100 * interval，即向前最多 100 个点的时间
  /// [to] 指定 K 线图的结束时间，不指定则默认当前时间，注意时间格式为秒(s)精度的 Unix 时间戳
  /// [interval] 数据点的时间间隔， 注意 30d 代表的是自然月，不是按30天对齐
  Future<List<List<String>>> candlesticks(String currencyPair,
      {int? limit, int? from, int? to, String? interval});
}
