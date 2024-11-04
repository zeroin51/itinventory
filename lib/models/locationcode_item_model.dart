class LocationCode {
  String id;
  String loccode;

  LocationCode({required this.id, required this.loccode});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loccode': loccode,
    };
  }

  static LocationCode fromMap(Map<String, dynamic> map, String documentId) {
    return LocationCode(
      id: documentId,
      loccode: map['loccode'],
    );
  }
}
