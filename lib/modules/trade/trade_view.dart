import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateio_flutter/widgets/kline/kline_view.dart';

class TradeView extends ConsumerWidget {
  const TradeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget kline = LayoutBuilder(
      builder: (context, constraints) => KlineView(
        currencyPair: 'BTC_USDT',
        interval: '1m',
        size: Size(constraints.maxWidth, constraints.maxHeight),
      ),
    );

    if (kIsWeb) {
      //
    } else if (Platform.isIOS || Platform.isAndroid) {
      // kline = Center(
      //   child: AspectRatio(
      //     aspectRatio: 1,
      //     child: kline,
      //   ),
      // );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: kline,
    );
  }
}
