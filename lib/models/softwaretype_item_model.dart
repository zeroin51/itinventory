class SoftwareType {
  String id;
  String softwaretype;

  SoftwareType({required this.id, required this.softwaretype});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'softwaretype': softwaretype,
    };
  }

  static SoftwareType fromMap(Map<String, dynamic> map, String documentId) {
    return SoftwareType(
      id: documentId,
      softwaretype: map['softwaretype'],
    );
  }
}
