import 'dart:convert';

class User {
  final String id;
  String name;
  String email;
  String role;
  String? cedula;
  String? phone;
  String? address;
  bool active;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'customer',
    this.cedula,
    this.phone,
    this.address,
    this.active = true,
  });

  /// Convertir User a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'cedula': cedula,
        'phone': phone,
        'address': address,
        'active': active,
      };

  /// Crear User desde JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        cedula: json['cedula'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        active: json['active'] == true || json['active'] == 1,
      );

  /// Codificar lista de Users a JSON string
  static String encodeList(List<User> users) =>
      json.encode(users.map((e) => e.toJson()).toList());

  /// Decodificar JSON string a lista de Users
  static List<User> decodeList(String source) {
    final list = json.decode(source) as List<dynamic>;
    return list.map((m) => User.fromJson(m as Map<String, dynamic>)).toList();
  }

  /// Crear copia del usuario con campos modificados
  User copyWith({
    String? name,
    String? email,
    String? role,
    String? cedula,
    String? phone,
    String? address,
    bool? active,
  }) =>
      User(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        cedula: cedula ?? this.cedula,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        active: active ?? this.active,
      );
}
