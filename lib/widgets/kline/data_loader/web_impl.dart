import 'package:gateio_flutter/widgets/kline/data/kline_data.dart';
import 'package:gateio_flutter/widgets/kline/data_loader/data_loader.dart';

class WebKlineDataLoaderImpl extends KlineDataLoader {
  @override
  // TODO: implement data
  KlineData get data => throw UnimplementedError();

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void request({
    required int offset,
    required int limit,
    required double drawWidth,
    required double drawHeight,
    required double scrollOffset,
  }) {
    // TODO: implement request
  }

  @override
  // TODO: implement stream
  Stream<KlineData> get stream => throw UnimplementedError();
}
