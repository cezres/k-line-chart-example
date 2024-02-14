import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

const kTickerRefreshInterval = Duration(seconds: 2);

@riverpod
class TickerStream extends _$TickerStream {
  @override
  Stream<Ticker> build() async* {
    final pair =
        ref.watch(currentCurrencyPairProvider.select((value) => value?.id));
    if (pair == null) {
      return;
    }

    bool isDisposed = false;
    ref.onDispose(() => isDisposed = true);

    while (!isDisposed) {
      try {
        final result = await GateApi.spot.tickers(pair);
        if (result.isNotEmpty) {
          yield result.first;
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
