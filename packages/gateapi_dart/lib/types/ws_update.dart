import 'package:json_annotation/json_annotation.dart';

part 'ws_update.g.dart';

@JsonSerializable()
class WsUpdate {
  WsUpdate(
      this.time, this.id, this.channel, this.event, this.error, this.result);

  final int time;
  final int id;
  final String channel;
  final String event;
  final int? error;
  final dynamic result;

  factory WsUpdate.fromJson(Map<String, dynamic> json) =>
      _$WsUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$WsUpdateToJson(this);
}
