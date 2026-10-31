import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Déjalo en false para usar tu servidor local en la computadora
  static const bool useRemote = true;
  
  // URL de tu backend desplegado en Render
  static const String _remoteUrl = 'https://active-sport-gym.onrender.com';

  static String get baseUrl {
    // Si useRemote está activo, usa Render
    if (useRemote) {
      return _remoteUrl;
    }

    // 1. Evaluar Web primero
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // 2. Evaluaciones para móviles
    if (Platform.isAndroid) {
      // CORRECCIÓN: El emulador de Android Studio requiere 10.0.2.2 para llegar al puerto 3000 de tu PC
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