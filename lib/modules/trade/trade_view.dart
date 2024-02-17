import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_line_chart_example/modules/trade/spot/spot_view.dart';

class TradeView extends ConsumerWidget {
  const TradeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: SpotView(),
    );
  }
}
