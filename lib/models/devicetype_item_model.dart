class DeviceType {
  String id;
  String devicetype;

  DeviceType({required this.id, required this.devicetype});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'devicetype': devicetype,
    };
  }

  static DeviceType fromMap(Map<String, dynamic> map, String documentId) {
    return DeviceType(
      id: documentId,
      devicetype: map['devicetype'],
    );
  }
}
