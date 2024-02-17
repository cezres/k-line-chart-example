import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/widgets/kline/kline_view.dart';

class TradeView extends ConsumerWidget {
  const TradeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      // child: SpotView(),
      child: LayoutBuilder(
        builder: (context, constraints) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: KlineView(
            currencyPair: 'BTC_USDT',
            interval: '1m',
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        ),
      ),
    );
  }
}
