class UserModel {
  final int? idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono;
  final String? cedula;
  final int? edad;
  final double? peso;
  final double? altura;
  final String password;
  final String? confirmarContrasena; 
  final String rol;

  UserModel({
    this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono,
    this.cedula,
    this.edad,
    this.peso,
    this.altura,
    required this.password,
    this.confirmarContrasena, 
    this.rol = 'cliente', // 👈 Actualizado a 'cliente' para coincidir con tu backend
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: json['id_usuario'] != null ? int.tryParse(json['id_usuario'].toString()) : null,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono']?.toString(),
      cedula: json['cedula']?.toString(),
      edad: json['edad'] != null ? int.tryParse(json['edad'].toString()) : null,
      peso: json['peso'] != null ? double.tryParse(json['peso'].toString()) : null,
      altura: json['altura'] != null ? double.tryParse(json['altura'].toString()) : null,
      password: '',
      rol: json['rol'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'cedula': cedula,
      'edad': edad,
      'peso': peso,
      'altura': altura,
      'contraseña': password,
      'confirmarContrasena': confirmarContrasena ?? password, 
      'rol': rol,
    };
  }
}