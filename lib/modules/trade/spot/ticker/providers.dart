import 'dart:async';

import 'package:decimal/decimal.dart';
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

    bool isCanceled = false;
    ref.onCancel(() {
      isCanceled = true;
    });

    while (!isCanceled) {
      try {
        final result = await GateApi.spot.tickers(pair);
        if (result.isNotEmpty) {
          yield result.first;
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }
}

@Riverpod()
class CurrentTicker extends _$CurrentTicker {
  @override
  Ticker build() {
    final pair =
        ref.watch(currentCurrencyPairProvider.select((value) => value?.id));
    _fetchTicker(pair);

    return Ticker(
        currencyPair: pair ?? '',
        last: '',
        lowestAsk: '',
        highestBid: '',
        changePercentage: Decimal.zero,
        baseVolume: Decimal.zero,
        quoteVolume: Decimal.zero,
        high24h: '',
        low24h: '',
        etfNetValue: '');
  }

  Timer? _timer;

  void _fetchTicker(String? pair) {
    _timer?.cancel();

    if (pair == null) {
      return;
    }

    final weakthis = WeakReference(this);
    _timer = Timer.periodic(kTickerRefreshInterval, (timer) async {
      final currentTicker = weakthis.target;
      if (currentTicker != null) {
        GateApi.spot.tickers(pair, timezone: Timezone.utc8).then((value) {
          if (value.isEmpty) {
            return;
          }
          final ticker = value.first;
          if (ticker.currencyPair == currentTicker.state.currencyPair) {
            currentTicker.state = value.first;
          } else {
            timer.cancel();
          }
        }).onError((error, stackTrace) {
          debugPrint(error.toString());
        });
      } else {
        timer.cancel();
      }
    });
  }
}
