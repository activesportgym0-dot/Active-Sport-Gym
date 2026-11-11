import 'package:flutter/material.dart';
import 'package:frontend/core/colores.dart';

// ============================================================================
// DATOS DEL GIMNASIO QUE APARECEN EN LOS TEXTOS: CÁMBIALOS AQUÍ, EN UN SOLO LUGAR
// ============================================================================
const String _nombreGimnasio = 'Active Sport Gym';
const String _ubicacionGimnasio = 'Garzón, Huila, Colombia';
const String _correoContacto = 'activesportgym0@gmail.com'; // <-- pon el correo real del gimnasio
const String _ultimaActualizacion = 'noviembre de 2026';

class _Seccion {
  final String titulo;
  final String texto;
  const _Seccion(this.titulo, this.texto);
}

// TÉRMINOS Y CONDICIONES
const List<_Seccion> _terminos = [
  _Seccion(
    '1. Aceptación',
    'Al crear una cuenta o usar la aplicación de $_nombreGimnasio ($_ubicacionGimnasio) aceptas estos términos y condiciones. Si no estás de acuerdo con ellos, no te registres ni uses la aplicación.',
  ),
  _Seccion(
    '2. Qué es esta aplicación',
    'Es la aplicación de los clientes de $_nombreGimnasio. Te permite consultar ejercicios, crear y seguir tus rutinas, registrar tu progreso y medidas, ver tu membresía, conocer las reglas y horarios del gimnasio y realizar compras dentro del gimnasio.',
  ),
  _Seccion(
    '3. Registro y activación de la cuenta',
    'La aplicación es para personas que van al gimnasio en Garzón, Huila. Para registrarte debes dar información real y completa: nombre, cédula, correo, teléfono, municipio y dirección donde vives, entre otros datos.\n\nDespués de verificar tu correo, el administrador del gimnasio revisará tu registro y activará tu cuenta. Hasta que esté activa no podrás iniciar sesión. El gimnasio puede no activar una cuenta, o desactivarla después, si los datos no son reales o si la persona no es cliente del gimnasio.',
  ),
  _Seccion(
    '4. Tu cuenta y tu contraseña',
    'Eres responsable de mantener en secreto tu contraseña y de todo lo que se haga con tu cuenta. Si crees que alguien más la está usando, avísale de inmediato al gimnasio. Tu cuenta es personal: no la prestes ni la compartas.',
  ),
  _Seccion(
    '5. Uso adecuado',
    'Te comprometes a no suplantar a otras personas, no dar datos falsos, no intentar entrar a cuentas ajenas, no dañar ni sobrecargar la aplicación y no usarla para fines distintos a los del gimnasio.',
  ),
  _Seccion(
    '6. Salud y actividad física',
    'Los ejercicios, las rutinas y las respuestas del asistente de inteligencia artificial son orientativos y no reemplazan la valoración de un médico ni de un profesional del deporte. Antes de empezar o cambiar tu entrenamiento, especialmente si tienes alguna condición de salud, consulta a un médico.\n\nEntrenas bajo tu propia responsabilidad. Si sientes dolor, mareo o malestar, detén el ejercicio y pide ayuda al personal del gimnasio.',
  ),
  _Seccion(
    '7. Membresías y compras',
    'Las membresías, sus precios, vigencias y condiciones de uso las define $_nombreGimnasio y se rigen por las reglas y horarios del gimnasio que puedes consultar en la aplicación. La información de tu membresía en la app es una consulta del estado registrado por el gimnasio.',
  ),
  _Seccion(
    '8. Propiedad intelectual',
    'La aplicación, su diseño, marca, textos, imágenes, videos y demás contenidos son de $_nombreGimnasio o de quienes lo autorizaron. No puedes copiarlos, distribuirlos ni usarlos fuera de la aplicación sin permiso.',
  ),
  _Seccion(
    '9. Suspensión y eliminación de la cuenta',
    'El gimnasio puede suspender o eliminar una cuenta si se incumplen estos términos. Tú puedes pedir que eliminemos tu cuenta y tus datos escribiendo a $_correoContacto.',
  ),
  _Seccion(
    '10. Cambios en estos términos',
    'Podemos actualizar estos términos. Cuando haya cambios importantes te lo avisaremos en la aplicación. Si sigues usándola después del aviso, entendemos que los aceptas.',
  ),
  _Seccion(
    '11. Ley aplicable y contacto',
    'Estos términos se rigen por las leyes de Colombia. Si tienes preguntas, escríbenos a $_correoContacto.',
  ),
];

// ---------------------------------------------------------------------------
// POLÍTICA DE TRATAMIENTO DE DATOS PERSONALES (Ley 1581 de 2012, Colombia)
// ---------------------------------------------------------------------------
const List<_Seccion> _datos = [
  _Seccion(
    '1. Quién es el responsable',
    'El responsable del tratamiento de tus datos personales es $_nombreGimnasio, ubicado en $_ubicacionGimnasio. Puedes contactarnos en $_correoContacto.',
  ),
  _Seccion(
    '2. Qué datos recogemos',
    '• Identificación y contacto: nombre, apellido, cédula, correo, teléfono, municipio y dirección (barrio o vereda).\n• Datos físicos y de salud: edad, peso, altura y las medidas corporales que registres en tu progreso.\n• Foto de perfil, si la subes.\n• Uso de la aplicación: rutinas, progreso, membresías, compras y conversaciones con el asistente.',
  ),
  _Seccion(
    '3. Para qué usamos tus datos',
    '• Crear tu cuenta, verificar tu correo y confirmar que eres cliente del gimnasio.\n• Que el administrador pueda activar o desactivar tu cuenta.\n• Gestionar tu membresía, tus compras y tu entrenamiento.\n• Mostrarte tu progreso y personalizar rutinas y recomendaciones.\n• Enviarte comunicaciones del servicio, como el código de verificación.\n• Mantener la seguridad de la aplicación.',
  ),
  _Seccion(
    '4. Datos sensibles',
    'El peso, la altura, las medidas corporales y la información sobre tu estado físico pueden considerarse datos sensibles porque se relacionan con tu salud. Son necesarios para el servicio de entrenamiento y seguimiento. Al aceptar esta política autorizas de forma expresa su tratamiento para esas finalidades. Nunca los usaremos para fines distintos ni los venderemos.',
  ),
  _Seccion(
    '5. Con quién los compartimos',
    'No vendemos tus datos. Solo los compartimos con proveedores tecnológicos que nos ayudan a operar la aplicación (por ejemplo, almacenamiento de información e imágenes y envío de correos) y cuando una autoridad competente lo exija. Tu información solo la ve el personal autorizado del gimnasio.',
  ),
  _Seccion(
    '6. Tus derechos',
    'Como titular de tus datos tienes derecho a:\n• Conocer, actualizar y rectificar tus datos.\n• Pedir prueba de la autorización que diste.\n• Saber cómo usamos tus datos.\n• Presentar quejas ante la Superintendencia de Industria y Comercio.\n• Revocar tu autorización y pedir que eliminemos tus datos, cuando la ley lo permita.\n\nPuedes actualizar muchos de tus datos desde tu perfil en la aplicación.',
  ),
  _Seccion(
    '7. Cómo ejercer tus derechos',
    'Escríbenos a $_correoContacto con tu nombre, cédula y lo que necesitas. Respondemos las consultas en máximo 10 días hábiles y los reclamos en máximo 15 días hábiles, y te avisaremos si necesitamos más tiempo, como lo establece la ley.',
  ),
  _Seccion(
    '8. Seguridad y conservación',
    'Protegemos tus datos con medidas técnicas y administrativas razonables, como contraseñas cifradas y acceso solo para personal autorizado. Los conservamos mientras tengas tu cuenta y el tiempo que exija la ley.',
  ),
  _Seccion(
    '9. Menores de edad',
    'Si eres menor de 18 años, necesitas la autorización de tu padre, madre o representante legal para registrarte y usar la aplicación.',
  ),
  _Seccion(
    '10. Cambios en esta política',
    'Si cambiamos esta política te avisaremos en la aplicación. La versión vigente siempre estará disponible en esta pantalla. Última actualización: $_ultimaActualizacion.',
  ),
];

/// Términos y condiciones + política de tratamiento de datos.
/// Se abre desde el registro y desde el inicio de sesión.
/// +0 = términos y condiciones, 1 = política de datos.
class TerminosCondicionesScreen extends StatelessWidget {
  final int tabInicial;

  const TerminosCondicionesScreen({super.key, this.tabInicial = 0});

  Widget _listaSecciones(String encabezado, List<_Seccion> secciones) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      children: [
        Text(
          encabezado,
          style: const TextStyle(
            color: AppColors.blancoPuro,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        for (final seccion in secciones) ...[
          Text(
            seccion.titulo,
            style: const TextStyle(
              color: AppColors.verdePrimario,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            seccion.texto,
            style: const TextStyle(
              color: AppColors.grisClaro,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: tabInicial,
      child: Scaffold(
        backgroundColor: AppColors.fondoNegro,
        appBar: AppBar(
          backgroundColor: AppColors.fondoNegro,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.verdePrimario, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'POLÍTICAS Y CONDICIONES',
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 16,
              color: AppColors.verdePrimario,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.verdePrimario,
            labelColor: AppColors.verdePrimario,
            unselectedLabelColor: AppColors.grisMedio,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'TÉRMINOS Y CONDICIONES'),
              Tab(text: 'TUS DATOS'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _listaSecciones(
                'Términos y condiciones de uso de la aplicación de $_nombreGimnasio. Última actualización: $_ultimaActualizacion.',
                _terminos,
              ),
              _listaSecciones(
                'Política de tratamiento de datos personales de $_nombreGimnasio, conforme a la Ley 1581 de 2012 de Colombia.',
                _datos,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
