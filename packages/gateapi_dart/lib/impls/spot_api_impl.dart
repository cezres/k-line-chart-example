import 'package:gateapi_dart/spot_api.dart';
import 'package:gateapi_dart/types/currency_pair.dart';

final class SpotApiImpl extends SpotApi {
  @override
  Future<List<CurrencyPair>> currencyPairs() {
    return dispatch('/spot/currency_pairs').then((value) =>
        (value as List).map((e) => CurrencyPair.fromJson(e)).toList());
  }
}
