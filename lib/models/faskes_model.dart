class FaskesModel {
  final String id;
  final String name;
  final String type; // puskesmas, rumah_sakit
  final String address;
  final String phone;
  final String operationalHours;
  final List<String> services;

  FaskesModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    required this.operationalHours,
    required this.services,
  });
}