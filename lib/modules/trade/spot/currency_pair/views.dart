import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/modules/trade/spot/currency_pair/providers.dart';

class CurrencyPairView extends ConsumerWidget {
  const CurrencyPairView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyPair = ref.watch(currentCurrencyPairProvider);
    if (currencyPair == null) {
      return const SizedBox.shrink();
    }
    return Text(
      "${currencyPair.base}/${currencyPair.quote}",
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
