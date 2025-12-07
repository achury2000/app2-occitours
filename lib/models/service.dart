// parte isa
// parte linsaith
// parte juanjo
/// Modelo que representa un servicio ofrecido en una finca.
///
/// Responsabilidades:
/// - Mantener datos de un servicio (duración, capacidad, precio, activo) y proveer conversión desde/hacia mapas.
///
/// Notas de implementación:
/// - `fromMap` parsea de forma defensiva campos numéricos y booleanos provenientes de CSV/JSON.
class Service {
  String id;
  String name;
  String description;
  int durationMinutes;
  int capacity;
  double price;
  bool active;

  Service({required this.id, required this.name, this.description = '', this.durationMinutes = 60, this.capacity = 1, this.price = 0.0, this.active = true});

  Map<String,dynamic> toMap(){
    return {'id': id, 'name': name, 'description': description, 'durationMinutes': durationMinutes, 'capacity': capacity, 'price': price, 'active': active};
  }

  factory Service.fromMap(Map<String,dynamic> m) => Service(
    id: (m['id'] ?? '').toString(),
    name: (m['name'] ?? '').toString(),
    description: (m['description'] ?? '').toString(),
    durationMinutes: (m['durationMinutes'] is int) ? m['durationMinutes'] as int : int.tryParse((m['durationMinutes'] ?? '60').toString()) ?? 60,
    capacity: (m['capacity'] is int) ? m['capacity'] as int : int.tryParse((m['capacity'] ?? '1').toString()) ?? 1,
    price: (m['price'] is double) ? m['price'] as double : double.tryParse((m['price'] ?? '0').toString()) ?? 0.0,
    active: m['active'] == null ? true : (m['active'].toString().toLowerCase()=='true')
  );
}
