import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gateapi_dart/gateapi_dart.dart';
import 'package:gateapi_dart/types/ws_update.dart';
import 'package:web_socket_channel/status.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsClient {
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  final Map<String, WsSubscribe> _channelOfSubscribes = {};
  final Map<int, WsSubscribe> _idOfSubscribes = {};

  Future connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(kWsURL));
    await _channel?.ready;

    /// 重新订阅
    for (final subscribe in _channelOfSubscribes.values) {
      _send({
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'id': subscribe.id,
        'channel': subscribe.channel,
        'event': 'subscribe',
        'payload': subscribe.payload,
      }).onError((error, stackTrace) {
        subscribe.onError(error);
      });
    }

    _channel?.stream.listen(
      (event) {
        try {
          final update = WsUpdate.fromJson(event);
          final subscribe = _idOfSubscribes[update.id];
          if (subscribe != null) {
            subscribe.onData(update);
          }
        } catch (e) {
          debugPrint('Error: $e');
        }
      },
      onDone: () {
        debugPrint('Done');
        // TODO: reconnect
      },
      onError: (error) {
        debugPrint('Error: $error');
        // TODO: reconnect
      },
    );

    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null && _channel?.closeCode == null) {
        _ping();
      } else {
        timer.cancel();
      }
    });
  }

  void close() {
    _channel?.sink.close(normalClosure);
    _pingTimer?.cancel();
  }

  WsSubscribe subscribe({required String channel, dynamic payload}) {
    if (_channelOfSubscribes.containsKey(channel)) {
      throw Exception('Already subscribed');
    }

    final subscribe = WsSubscribe(123, channel, payload, null);
    _channelOfSubscribes[subscribe.channel] = subscribe;
    _idOfSubscribes[subscribe.id] = subscribe;

    _send({
      'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'id': 123,
      'channel': channel,
      'event': 'subscribe',
      'payload': payload,
    }).onError((error, stackTrace) {
      subscribe.onError(error);
    });

    return subscribe;
  }

  void unsubscribe(WsSubscribe subscribe) {
    _send({
      'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'id': subscribe.id,
      'channel': subscribe.channel,
      'event': 'unsubscribe',
      'payload': subscribe.payload,
    }).onError((error, stackTrace) {
      subscribe.onError(error);
    });

    subscribe.onClose();
    _channelOfSubscribes.remove(subscribe.channel);
    _idOfSubscribes.remove(subscribe.id);
  }

  void _ping() {
    _send(
      {
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'channel': 'spot.ping',
      },
    );
  }

  Future _send(Map data) async {
    if (_channel == null) {
      throw Exception('Not connected');
    }
    await _channel?.ready;
    data.removeWhere((key, value) => value == null);
    _channel?.sink.add(json.encode(data));
  }
}

class WsSubscribe {
  WsSubscribe(this.id, this.channel, this.payload, this.auth);

  final int id;
  final String channel;
  final dynamic payload;
  final dynamic auth;
  final _controller = StreamController<WsUpdate>.broadcast();

  Stream<WsUpdate> get stream => _controller.stream;

  void onData(dynamic data) {
    _controller.add(data);
  }

  void onError(dynamic error) {
    _controller.addError(error);
  }

  void onClose() {
    _controller.close();
  }
}
