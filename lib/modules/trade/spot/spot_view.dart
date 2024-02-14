import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/modules/trade/spot/candlesticks/views.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/views.dart';
import 'package:gateio_flutter/modules/trade/spot/order_book/views.dart';
import 'package:gateio_flutter/modules/trade/spot/ticker/views.dart';

class SpotView extends ConsumerWidget {
  const SpotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const CurrencyPairView(),
        const TickerView(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CandlesticksView(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: OrderBookView(),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            //
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('data'),
                  ),
                  body: const OrderBookView(),
                ),
              ),
            );
          },
          child: const Text('data'),
        ),
      ],
    );
  }
}
