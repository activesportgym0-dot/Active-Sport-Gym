import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    // 1. Evaluar Web primero
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // 2. Evaluaciones para móviles / emulador
    if (Platform.isAndroid) {
      // Emulador de Android apuntando a tu backend Express
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    }

    return 'http://localhost:3000';
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}