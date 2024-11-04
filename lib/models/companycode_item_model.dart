class CompanyCode {
  String id;
  String comcode;

  CompanyCode({required this.id, required this.comcode});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comcode': comcode,
    };
  }

  static CompanyCode fromMap(Map<String, dynamic> map, String documentId) {
    return CompanyCode(
      id: documentId,
      comcode: map['comcode'],
    );
  }
}
