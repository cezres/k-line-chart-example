// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WsUpdate _$WsUpdateFromJson(Map<String, dynamic> json) => WsUpdate(
      json['time'] as int,
      json['id'] as int,
      json['channel'] as String,
      json['event'] as String,
      json['error'] as int?,
      json['result'],
    );

Map<String, dynamic> _$WsUpdateToJson(WsUpdate instance) => <String, dynamic>{
      'time': instance.time,
      'id': instance.id,
      'channel': instance.channel,
      'event': instance.event,
      'error': instance.error,
      'result': instance.result,
    };
