import 'package:flutter/material.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
class CandlesticksStream extends _$CandlesticksStream {
  @override
  Stream<List<List<String>>> build() async* {
    final currencyPair = ref.watch(currentCurrencyPairProvider);
    if (currencyPair == null) {
      return;
    }

    try {
      final data = await GateApi.spot.candlesticks(
        currencyPair.id,
        interval: '1h',
        limit: 100,
      );
      yield data;
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
