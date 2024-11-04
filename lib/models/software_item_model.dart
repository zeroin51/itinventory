class SoftwareItem {
  String id;
  String noasset;
  String noserial;
  String type; 
  String expdate;
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

  SoftwareItem({required this.id, required this.noasset, required this.noserial, required this.type, required this.expdate,  required this.assetdesc, required this.costcenter, required this.companycode, required this.picname, required this.loccode, required this.locdesc, required this.kondisi, required this.label, required this.note, required this.imageUrl});

  get imagePath => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noasset': noasset,
      'noserial': noserial,
      'type': type,
      'expdate':expdate,
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
    };
  }

  static SoftwareItem fromMap(Map<String, dynamic> map, String documentId) {
    return SoftwareItem(
      id: documentId,
      noasset: map['noasset'],
      noserial: map['noserial'],
      type: map['type'],
      expdate: map['expdate'],
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
    );
  }
}
