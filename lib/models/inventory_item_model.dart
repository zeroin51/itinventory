class InventoryItem {
  String id;
  String noasset;
  String noserial;
  String type; // "Device" atau "Software"
  String details;
  String imageUrl;

  InventoryItem({required this.id, required this.noasset, required this.noserial, required this.type, required this.details, required this.imageUrl});

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

  static InventoryItem fromMap(Map<String, dynamic> map, String documentId) {
    return InventoryItem(
      id: documentId,
      noasset: map['noasset'],
      noserial: map['noserial'],
      type: map['type'],
      details: map['details'],
      imageUrl: map['imageUrl'],
    );
  }
}
