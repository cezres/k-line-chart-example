// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'k_line_data_loader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$klineDataHash() => r'755751af61811265e64e3aa4587cec9d449b5eba';

/// K线数据加载器
/// 将数据加载和解析任务放到独立的 Isolate 中执行
///
/// Copied from [klineData].
@ProviderFor(klineData)
final klineDataProvider = StreamProvider<KlineData>.internal(
  klineData,
  name: r'klineDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$klineDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef KlineDataRef = StreamProviderRef<KlineData>;
String _$klineDataLoaderHash() => r'4b406b5385fba398245aeea29cd2bfa40995e521';

/// See also [KlineDataLoader].
@ProviderFor(KlineDataLoader)
final klineDataLoaderProvider =
    NotifierProvider<KlineDataLoader, KlineDataLoaderState>.internal(
  KlineDataLoader.new,
  name: r'klineDataLoaderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$klineDataLoaderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$KlineDataLoader = Notifier<KlineDataLoaderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
