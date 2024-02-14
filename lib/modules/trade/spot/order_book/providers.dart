import 'package:flutter/material.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateapi_dart/types/order_book.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
class OrderBookStream extends _$OrderBookStream {
  @override
  Stream<OrderBook> build() async* {
    final pair = ref.watch(currentCurrencyPairProvider);
    if (pair == null) {
      yield const OrderBook(id: 0, current: 0, update: 0, asks: [], bids: []);
      return;
    }

    bool isCanceled = false;
    ref.onCancel(() {
      isCanceled = true;
    });

    while (!isCanceled) {
      try {
        yield await GateApi.spot
            .orderBook(pair.id, interval: '1', limit: 10, withId: true);
      } catch (e) {
        debugPrint('Error: $e');
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }
}
