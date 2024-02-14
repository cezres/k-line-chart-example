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
}
