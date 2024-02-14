// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderBook _$OrderBookFromJson(Map<String, dynamic> json) => OrderBook(
      id: json['id'] as int,
      current: json['current'] as int,
      update: json['update'] as int,
      asks: (json['asks'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => Decimal.fromJson(e as String))
              .toList())
          .toList(),
      bids: (json['bids'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => Decimal.fromJson(e as String))
              .toList())
          .toList(),
    );

Map<String, dynamic> _$OrderBookToJson(OrderBook instance) => <String, dynamic>{
      'id': instance.id,
      'current': instance.current,
      'update': instance.update,
      'asks': instance.asks,
      'bids': instance.bids,
    };
