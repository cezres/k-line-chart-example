import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class KLineChartConfiguration extends _$KLineChartConfiguration {
  @override
  KLineChartConfigurationEntity build() {
    return const KLineChartConfigurationEntity();
  }

  void setInterval(String interval) {
    state = state.copyWith(interval: interval);
  }
}

final class KLineChartConfigurationEntity {
  const KLineChartConfigurationEntity({
    this.interval = '1h',
  });

  final String interval;

  KLineChartConfigurationEntity copyWith({
    String? interval,
  }) {
    return KLineChartConfigurationEntity(
      interval: interval ?? this.interval,
    );
  }
}
