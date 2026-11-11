import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  responseDataCallback: (data) => writeResponseData(
    data,
    testOutputFilename: 't061_trace_actions',
    destinationDirectory: 'specs/002-visual-design-motion/evidence/traces',
  ),
);
