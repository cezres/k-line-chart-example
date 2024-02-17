import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateapi_dart/spot_api.dart';
import 'package:gateapi_dart/types/order_book.dart';

final class SpotApiImpl extends SpotApi {
  @override
  Future<List<CurrencyPair>> currencyPairs() {
    return dispatch('/spot/currency_pairs').then((value) =>
        (value as List).map((e) => CurrencyPair.fromJson(e)).toList());
  }

  @override
  Future<List<Ticker>> tickers(String? currencyPair,
      {Timezone timezone = Timezone.utc8}) {
    return dispatch(
      '/spot/tickers',
      params: {
        'currency_pair': currencyPair,
        'timezone': timezone.name,
      },
    ).then((value) => (value as List).map((e) => Ticker.fromJson(e)).toList());
  }

  @override
  Future<OrderBook> orderBook(String currencyPair,
      {String? interval, int? limit, bool? withId}) {
    return dispatch(
      '/spot/order_book',
      params: {
        'currency_pair': currencyPair,
        'interval': interval,
        'limit': limit,
        'with_id': withId,
      },
    ).then((value) => OrderBook.fromJson(value));
  }

  @override
  Future<List<List<String>>> candlesticks(String currencyPair,
      {int? limit, int? from, int? to, String? interval}) {
    return dispatch(
      '/spot/candlesticks',
      params: {
        'currency_pair': currencyPair,
        'limit': limit,
        'from': from,
        'to': to,
        'interval': interval,
      },
    ).then((value) {
      return (value as List).map((e) {
        return (e as List).map((e) => e.toString()).toList();
      }).toList();
    });
  }
}

// https://api.gateio.ws/api/v4/spot/candlesticks?currency_pair=BTC_USDT&limit=1000&interval=1m
// https://api.gateio.ws/api/v4/spot/candlesticks?currency_pair=BTC_USDT&interval=1m&to=1708047720&from=1707987780