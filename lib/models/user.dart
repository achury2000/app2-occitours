class User {
  final String id;
  String name;
  String? apellido;
  String email;
  String role;
  String? cedula;
  String? phone;
  String? address;
  bool active;

  User(
      {required this.id,
      required this.name,
      this.apellido,
      required this.email,
      this.role = 'customer',
      this.cedula,
      this.phone,
      this.address,
      this.active = true});
}
