import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/views.dart';
import 'package:gateio_flutter/modules/trade/spot/order_book/views.dart';
import 'package:gateio_flutter/modules/trade/spot/ticker/views.dart';
import 'package:gateio_flutter/widgets/custom_chart/custom_chart.dart';

class SpotView extends ConsumerWidget {
  const SpotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // const kline = CustomChart();
    // const pair = CurrencyPairView();
    // const ticker = TickerView();
    // const depth = OrderBookView();

    final size = MediaQuery.of(context).size;

    if (size.width > 600) {
      return const Column(
        children: [
          // Padding(
          //   padding: EdgeInsets.only(bottom: 16),
          //   child: Row(
          //     children: [
          //       pair,
          //       Expanded(
          //         child: ticker,
          //       ),
          //     ],
          //   ),
          // ),
          // Expanded(
          //   child: Row(
          //     children: [
          //       Expanded(child: kline),
          //       Padding(
          //         padding: EdgeInsets.only(left: 20),
          //         child: depth,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      );
    } else {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CurrencyPairView(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: TickerView(),
          ),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: CustomChart(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: OrderBookView(),
          ),
        ],
      );
    }
  }
}
