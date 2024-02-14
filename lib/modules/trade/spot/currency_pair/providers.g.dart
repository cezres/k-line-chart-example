// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentCurrencyPairHash() =>
    r'ab8370689b49d684d1a0d6db82c46033360a09fe';

/// See also [CurrentCurrencyPair].
@ProviderFor(CurrentCurrencyPair)
final currentCurrencyPairProvider =
    NotifierProvider<CurrentCurrencyPair, CurrencyPair?>.internal(
  CurrentCurrencyPair.new,
  name: r'currentCurrencyPairProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCurrencyPairHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentCurrencyPair = Notifier<CurrencyPair?>;
String _$currencyPairsHash() => r'03fce7f32e468c75b1236482370e964d5ba071d2';

/// See also [CurrencyPairs].
@ProviderFor(CurrencyPairs)
final currencyPairsProvider =
    AsyncNotifierProvider<CurrencyPairs, List<CurrencyPair>>.internal(
  CurrencyPairs.new,
  name: r'currencyPairsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencyPairsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrencyPairs = AsyncNotifier<List<CurrencyPair>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
