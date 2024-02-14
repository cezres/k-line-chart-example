import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/views.dart';
import 'package:gateio_flutter/modules/trade/spot/order_book/views.dart';
import 'package:gateio_flutter/modules/trade/spot/ticker/views.dart';

class SpotView extends ConsumerWidget {
  const SpotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      children: [
        CurrencyPairView(),
        TickerView(),
        OrderBookView(),
      ],
    );
  }
}
