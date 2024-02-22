class MembershipPlanModel{
  MembershipPlanModel({
    this.id,
    this.user,
    this.plan,
    this.validity,
    this.basePrice,
    this.sellingPrice,
    this.GSTincluded,
    this.gstRate,
    this.cgst,
    this.sgst,
    this.igst
  });
  String? id;
  String? user;
  String? plan;
  int? validity;
  String? basePrice;
  double? sellingPrice;
  bool? GSTincluded;
  String? gstRate;
  String? cgst;
  String? sgst;
  String? igst;

  Map<String, dynamic> toMap(){
    return{
      "_id": id,
      "user": user,
      "plan": plan,
      "validity": validity,
      "basePrice": basePrice,
      "sellingPrice": sellingPrice,
      "GSTincluded": GSTincluded,
      "GSTRate": gstRate,
      "CGST": cgst,
      "SGST": sgst,
      "IGST": igst
    };
  }
  factory MembershipPlanModel.fromMap(map){
    return MembershipPlanModel(
      id: map['_id'],
      user: map['user'],
      plan: map['plan'],
      validity: map['validity'],
      basePrice: map['basePrice'].toString(),
      sellingPrice: map['sellingPrice'] != null ? double.parse(map['sellingPrice'].toString()) : 0,
      GSTincluded: map['GSTincluded'],
      gstRate: map['GSTRate'].toString(),
      cgst: map['CGST'].toString(),
      sgst: map['SGST'].toString(),
      igst: map['IGST'].toString(),
    );
  }
}