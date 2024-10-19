class DeviceItem {
  String id;
  String noasset;
  String noserial;
  String type; 
  String details;
  String imageUrl;

  DeviceItem({required this.id, required this.noasset, required this.noserial, required this.type, required this.details, required this.imageUrl});

  get imagePath => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noasset': noasset,
      'noserial': noserial,
      'type': type,
      'details': details,
      'imageUrl': imageUrl,
    };
  }

  static DeviceItem fromMap(Map<String, dynamic> map, String documentId) {
    return DeviceItem(
      id: documentId,
      noasset: map['noasset'],
      noserial: map['noserial'],
      type: map['type'],
      details: map['details'],
      imageUrl: map['imageUrl'],
    );
  }
}
