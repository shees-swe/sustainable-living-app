import 'package:flutter/services.dart';

class UserDataFilePicker {
  const UserDataFilePicker();

  static const MethodChannel _channel = MethodChannel(
    'app.sustainablelivingguide/user_data_import',
  );

  Future<Uint8List?> pickJsonFile() =>
      _channel.invokeMethod<Uint8List>('pickJsonFile');
}
