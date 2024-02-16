library gateapi_dart;

export './types/currency_pair.dart';
export './types/timezone.dart';
export './types/ticker.dart';

import 'package:gateapi_dart/impls/spot_api_impl.dart';
import 'package:gateapi_dart/spot_api.dart';

const String kBaseURL = 'https://api.gateio.ws/api/v4';
const String kWsURL = 'wss://api.gateio.ws/ws/v4/';

final class GateApi {
  static SpotApi spot = SpotApiImpl();
}
