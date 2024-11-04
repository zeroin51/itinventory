class CostCenter {
  String id;
  String kodeCC;
  String detail;

  CostCenter({required this.id, required this.kodeCC, required this.detail});

  Map<String, dynamic> toMap() {
    return {
      'kodeCC': kodeCC,
      'detail': detail,
    };
  }

  static CostCenter fromMap(Map<String, dynamic> map, String documentId) {
    return CostCenter(
      id: documentId,
      kodeCC: map['kodeCC'] ?? '',
      detail: map['detail'] ?? '',
    );
  }
}
