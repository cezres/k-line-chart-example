// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticker _$TickerFromJson(Map<String, dynamic> json) => Ticker(
      currencyPair: json['currency_pair'] as String,
      last: json['last'] as String,
      lowestAsk: json['lowest_ask'] as String,
      highestBid: json['highest_bid'] as String,
      changePercentage: Decimal.fromJson(json['change_percentage'] as String),
      baseVolume: Decimal.fromJson(json['base_volume'] as String),
      quoteVolume: Decimal.fromJson(json['quote_volume'] as String),
      high24h: json['high_24h'] as String,
      low24h: json['low_24h'] as String,
      etfNetValue: json['etf_net_value'] as String?,
      etfPreNetValue: json['etf_pre_net_value'] as String?,
      etfPreTimestamp: json['etf_pre_timestamp'] as int?,
      etfLeverage: json['etf_leverage'] as String?,
    );

Map<String, dynamic> _$TickerToJson(Ticker instance) => <String, dynamic>{
      'currency_pair': instance.currencyPair,
      'last': instance.last,
      'lowest_ask': instance.lowestAsk,
      'highest_bid': instance.highestBid,
      'change_percentage': instance.changePercentage,
      'base_volume': instance.baseVolume,
      'quote_volume': instance.quoteVolume,
      'high_24h': instance.high24h,
      'low_24h': instance.low24h,
      'etf_net_value': instance.etfNetValue,
      'etf_pre_net_value': instance.etfPreNetValue,
      'etf_pre_timestamp': instance.etfPreTimestamp,
      'etf_leverage': instance.etfLeverage,
    };
