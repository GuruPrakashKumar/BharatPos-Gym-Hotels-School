class MembershipPlanInput{
  MembershipPlanInput({
    this.user,
    this.plan,
    this.validity,
    this.basePrice,
    this.sellingPrice,
    this.GSTincluded,
    this.gstRate,
    this.cgst,
    this.sgst,
    this.igst,
    this.id,
    this.gst = false,
    this.subscription_type
  });
  String? id;
  String? user;
  String? plan;
  String? validity;
  String? basePrice;
  String? sellingPrice;
  String? subscription_type;
  bool gst;
  bool? GSTincluded;
  String? gstRate;
  String? cgst;
  String? sgst;
  String? igst;

  Map<String, dynamic> toMap(){
    return{
      "user": user,
      "plan": plan,
      "validity": validity,
      "sellingPrice": sellingPrice,
      "subscription_type": subscription_type,
      if(gst) "basePrice": basePrice,
      if(gst) "GSTincluded": GSTincluded,
      if(gst) "GSTRate": gstRate,
      if(gst) "CGST": cgst,
      if(gst) "SGST": sgst,
      if(gst) "IGST": igst,
      "id": id
    };
  }
  factory MembershipPlanInput.fromMap(map){
    return MembershipPlanInput(
      id: map['_id'],
      user: map['user'],
      plan: map['plan'],
      subscription_type: map['subscription_type'],
      validity: map['validity'].toString(),
      basePrice: map['basePrice'].toString(),
      sellingPrice: map['sellingPrice'].toString(),
      GSTincluded: map['GSTincluded'],
      gstRate: map['GSTRate'].toString(),
      cgst: map['CGST'].toString(),
      sgst: map['SGST'].toString(),
      igst: map['IGST'].toString(),
    );
  }
}