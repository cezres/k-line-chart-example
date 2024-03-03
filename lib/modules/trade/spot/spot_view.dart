import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:k_line_chart_example/modules/trade/spot/currency_pair/views.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/data_loader/data_loader.dart';
import 'package:k_line_chart_example/modules/trade/spot/ticker/views.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_view.dart';

class SpotView extends ConsumerWidget {
  const SpotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return LayoutBuilder(
        builder: (context, constraints) => KlineView(
          currencyPair: 'BTC_USDT',
          interval: '1m',
          size: Size(constraints.maxWidth, constraints.maxHeight),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CurrencyPairView(),
            // const Padding(
            //   padding: EdgeInsets.symmetric(vertical: 16),
            //   child: TickerView(),
            // ),
            AspectRatio(
              aspectRatio: 3 / 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxHeight == 0 || constraints.maxWidth == 0) {
                    return const SizedBox();
                  }
                  return KlineView(
                    currencyPair: 'BTC_USDT',
                    interval: '1m',
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  );
                },
              ),
            ),
            // FutureBuilder(
            //   future: GateApi.spot.candlesticks(kDefaultCurrencyPair, limit: 20),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     } else {
            //       final data = snapshot.data as List<List<dynamic>>;
            //       return Text('Data: ${data.length}');
            //     }
            //   },
            // ),
            // const Padding(
            //   padding: EdgeInsets.only(top: 16),
            //   child: OrderBookView(),
            // ),
          ],
        ),
      );
    }
  }
}
