import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/data_loader/impl.dart';

class WebKlineDataLoaderImpl extends KlineDataLoaderImpl {
  int _index = 0;

  @override
  void loadLast() async {
    final datas = await _loadDatasFromAsset('assets/candlesticks_0.json');
    appendLastPoints(datas);
  }

  bool _loadingFirst = false;

  @override
  void loadFirst() async {
    if (_loadingFirst) {
      return;
    }
    _loadingFirst = true;
    if (_index == 7) {
      return;
    }

    _index++;

    final datas = await _loadDatasFromAsset('assets/candlesticks_$_index.json');
    appendFirstPoints(datas);
    _loadingFirst = false;
  }

  Future<List<List<String>>> _loadDatasFromAsset(String key) async {
    final result = await rootBundle.loadString('assets/candlesticks_$_index.json');
    final datas = json.decode(result);

    return (datas as List).map((e) => (e as List).map((e) => e.toString()).toList()).toList();
  }
}
