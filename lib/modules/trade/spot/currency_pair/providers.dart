import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class CurrentCurrencyPair extends _$CurrentCurrencyPair {
  @override
  CurrencyPair? build() {
    final asyncValue = ref.watch(currencyPairsProvider);
    if (asyncValue.hasValue) {
      final pairs = asyncValue.requireValue;
      if (pairs.isNotEmpty) {
        return pairs.firstWhere(
          (element) => element.id == 'BTC_USDT',
          orElse: () => pairs.first,
        );
      }
    }
    return null;
  }

  void set(CurrencyPair? value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
class CurrencyPairs extends _$CurrencyPairs {
  @override
  FutureOr<List<CurrencyPair>> build() {
    return GateApi.spot.currencyPairs();
  }
}
