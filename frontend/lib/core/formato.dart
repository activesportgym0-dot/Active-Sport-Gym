/// Utilidades de formato compartidas por las pantallas de la app.
class Formato {
  Formato._();

  /// 120000 -> $120.000 (acepta num o String, como llega del backend).
  static String precio(dynamic valor) {
    final numero = num.tryParse(valor?.toString() ?? '') ?? 0;
    final texto = numero.round().toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '\$${texto.replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  /// 120000.00 -> "120000" (sirve para precargar campos numéricos y mostrar stock).
  static String entero(dynamic valor) {
    final numero = num.tryParse(valor?.toString() ?? '') ?? 0;
    return numero.round().toString();
  }
}
