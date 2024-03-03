import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:k_line_chart_example/modules/home/home_page.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/data_loader/data_loader.dart';
// import 'package:window_manager/window_manager.dart';

// flutter run -d chrome --web-renderer skwasm --release
// flutter run -d chrome --web-renderer canvaskit --release

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // const windowOptions = WindowOptions(
  //   size: Size(800, 600),
  //   minimumSize: Size(800, 600),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   // skipTaskbar: false,
  //   // titleBarStyle: TitleBarStyle.hidden,
  // );
  // await windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });

  int? to;
  for (var i = 0; i < 8; i++) {
    final data = await GateApi.spot.candlesticks(
      kDefaultCurrencyPair,
      interval: kDefaultInterval,
      limit: to == null ? 1000 : null,
      to: to,
      from: to == null ? null : to - 60 * 999,
    );
    print('to: ${data.first[0]}~${data.last[0]} ${data.length}');
    to = int.parse(data.first[0]) - 60;

    final string = json.encode(data);
    File('/Users/cezres/Downloads/Button/candlesticks_$i.json').writeAsStringSync(string);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-Line Flutter Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
