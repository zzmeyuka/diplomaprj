import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isAndroid) return 'https://blemish-vividness-unsuited.ngrok-free.dev/api';
    return 'http://localhost:3000/api';
  }
}

