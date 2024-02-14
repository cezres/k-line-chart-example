// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tickerStreamHash() => r'1aa012bcc1e3e27cbc000f94401e1e0c7a155d50';

/// See also [TickerStream].
@ProviderFor(TickerStream)
final tickerStreamProvider =
    AutoDisposeStreamNotifierProvider<TickerStream, Ticker>.internal(
  TickerStream.new,
  name: r'tickerStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tickerStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TickerStream = AutoDisposeStreamNotifier<Ticker>;
String _$currentTickerHash() => r'e30545c09981b434070e383170406d995e73b527';

/// See also [CurrentTicker].
@ProviderFor(CurrentTicker)
final currentTickerProvider =
    AutoDisposeNotifierProvider<CurrentTicker, Ticker>.internal(
  CurrentTicker.new,
  name: r'currentTickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentTickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentTicker = AutoDisposeNotifier<Ticker>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
