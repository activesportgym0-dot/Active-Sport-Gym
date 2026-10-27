import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

class EstiloTexto {
  // --- TÍTULOS ---
  static TextStyle titulos = const TextStyle(
    fontFamily: 'BebasNeue',
  );
  
  static TextStyle tituloBienvenida = const TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 2.0,
    shadows: [
      Shadow(
        color: Colors.black,
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  );

  static TextStyle tituloPrincipalPrimerPantalla = const TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 35,
    fontWeight: FontWeight.w300,
    color: Colors.white,
    letterSpacing: 0.5,
    height: 1.2,
    shadows: [
      Shadow(
        color: Colors.black,
        blurRadius: 8,
        offset: Offset(0, 6),
      ),
    ],
  );

  // --- NUEVOS ESTILOS CON TEKO (Para títulos de secciones y encabezados de rutina) ---
  static TextStyle tekoTituloSeccion = const TextStyle(
    fontFamily: 'Teko',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.verdePrimario,
    letterSpacing: 1.2,
  );

  static TextStyle tekoSubtituloSeccion = const TextStyle(
    fontFamily: 'Teko',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle tekoEtiquetaForm = const TextStyle(
    fontFamily: 'Teko',
    fontSize: 16,
    color: Colors.white,
  );

  // --- BOTONES ---
  static TextStyle botonPrincipal = const TextStyle(
    fontFamily: 'Oswald',
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // --- FORMULARIOS Y TEXTOS GENERALES ---
  static TextStyle bienvenida = const TextStyle(
    fontFamily: 'Oswald',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  // --- ROBOTO (Para subtítulos descriptivos) ---
  static TextStyle subtituloRoboto = const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 12,
    color: Colors.grey,
  );

  static TextStyle textoAyudaRoboto = const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    color: Colors.grey,
  );

  static TextStyle campoTexto = const TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  static TextStyle hintTexto = const TextStyle(
    color: Colors.white54,
    fontSize: 14,
  );

  // --- TEXTOS SECUNDARIOS Y FORMULARIOS (Roboto Condensed) ---
  static TextStyle textoNormalRoboto = const TextStyle(
    fontFamily: 'RobotoCondensed',
    fontWeight: FontWeight.bold,
    color: Colors.white70,
    fontSize: 13,
  );

  static TextStyle enlaceNegritaRoboto = const TextStyle(
    fontFamily: 'RobotoCondensed',
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  static TextStyle politicasRoboto = const TextStyle(
    fontFamily: 'RobotoCondensed',
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  // --- NOSIFER (Para las iniciales de los días en la Estructura Semanal) ---
  static TextStyle nosiferDiasSemana = const TextStyle(
    fontFamily: 'Nosifer',
    fontSize: 12,
    color: Colors.white,
  );
}