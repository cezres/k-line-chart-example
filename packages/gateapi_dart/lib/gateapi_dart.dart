library gateapi_dart;

import 'package:gateapi_dart/impls/spot_api_impl.dart';
import 'package:gateapi_dart/spot_api.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

// const String kBaseURL = 'https://api.gate.io/api/v4';
const String kBaseURL = 'https://api.gateio.ws/api/v4';

final class GateApi {
  static SpotApi spot = SpotApiImpl();
}
