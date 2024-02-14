import 'package:gateapi_dart/impls/api_client.dart';
import 'package:gateapi_dart/types/currency_pair.dart';

/// 现货交易
abstract class SpotApi extends ApiClient {
  // /// 查询所有币种信息
  // void currencies();

  /// 查询支持的所有交易对
  Future<List<CurrencyPair>> currencyPairs();
}
