class DeviceItem {
  String id;
  String noasset;
  String noserial;
  String type; 
  String assetdesc;
  String costcenter;
  String companycode;
  String picname;
  String loccode;
  String locdesc;
  String kondisi;
  String label;
  String note;
  String imageUrl;
  String imagename;

  DeviceItem({required this.id, required this.noasset, required this.noserial, required this.type, required this.assetdesc, required this.costcenter, required this.companycode, required this.picname, required this.loccode, required this.locdesc, required this.kondisi, required this.label, required this.note, required this.imageUrl, required this.imagename});

  get imagePath => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noasset': noasset,
      'noserial': noserial,
      'type': type,
      'assetdesc': assetdesc,
      'costcenter': costcenter,
      'companycode': companycode,
      'picname': picname,
      'loccode': loccode,
      'locdesc': locdesc,
      'kondisi': kondisi,
      'label': label,
      'note': note,
      'imageUrl': imageUrl,
      'imagename': imagename,
    };
  }

  static DeviceItem fromMap(Map<String, dynamic> map, String documentId) {
    return DeviceItem(
      id: documentId,
      noasset: map['noasset'],
      noserial: map['noserial'],
      type: map['type'],
      assetdesc: map['assetdesc'],
      costcenter: map['costcenter'],
      companycode: map['companycode'],
      picname: map['picname'],
      loccode: map['loccode'],
      locdesc: map['locdesc'],
      kondisi: map['kondisi'],
      label: map['label'],
      note: map['note'],
      imageUrl: map['imageUrl'],
      imagename: map['imagename']
    );
  }
}
