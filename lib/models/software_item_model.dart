class SoftwareItem {
  String id;
  String noasset;
  String noserial;
  String type; 
  String expdate;
  String details;
  String imageUrl;

  SoftwareItem({required this.id, required this.noasset, required this.noserial, required this.type, required this.expdate, required this.details, required this.imageUrl});

  get imagePath => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noasset': noasset,
      'noserial': noserial,
      'type': type,
      'expdate':expdate,
      'details': details,
      'imageUrl': imageUrl,
    };
  }

  static SoftwareItem fromMap(Map<String, dynamic> map, String documentId) {
    return SoftwareItem(
      id: documentId,
      noasset: map['noasset'],
      noserial: map['noserial'],
      type: map['type'],
      expdate: map['expdate'],
      details: map['details'],
      imageUrl: map['imageUrl'],
    );
  }
}
