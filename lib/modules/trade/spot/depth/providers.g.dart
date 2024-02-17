// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderBookStreamHash() => r'00a347b783fc8b37264b7d039703f30f94d05dd3';

/// See also [OrderBookStream].
@ProviderFor(OrderBookStream)
final orderBookStreamProvider =
    AutoDisposeStreamNotifierProvider<OrderBookStream, OrderBook>.internal(
  OrderBookStream.new,
  name: r'orderBookStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderBookStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrderBookStream = AutoDisposeStreamNotifier<OrderBook>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
