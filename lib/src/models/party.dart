class Party {
  Party(
      {this.name,
      this.phoneNumber,
      this.id,
      this.createdAt,
      this.totalCreditAmount,
      this.totalSettleAmount,
      this.v,
      this.total,
      this.type,
      this.balance,
      this.address,
        this.guardianName,
      this.modeOfPayment});

  String? name;
  String? phoneNumber;
  String? id;
  String? modeOfPayment;
  String? address;
  DateTime? createdAt;
  String? type;
  String? v;
  String? guardianName;
  double? totalCreditAmount;
  double? totalSettleAmount;
  double? total;
  double? balance;


  factory Party.fromMapTemp(Map<String, dynamic> json, double due) => Party(
    name: json["name"],
    phoneNumber: json["phoneNumber"].toString(),
    id: json["_id"],
    type: json['type'],
    createdAt: DateTime.parse(json["createdAt"]),
    guardianName: json['guardianName'],
    balance: due.toDouble(),
    address: json["address"],
    totalCreditAmount: 0,
    totalSettleAmount: 0,
    total: 0
  );

  factory Party.fromMap(Map<String, dynamic> json) => Party(
        name: json["name"],
        phoneNumber: json["phoneNumber"].toString(),
        id: json["_id"],
        type: json['type'],
        createdAt: DateTime.parse(json["createdAt"]),
      guardianName: json['guardianName'],
        totalCreditAmount: json['totalCreditAmount']!=null? double.parse(json['totalCreditAmount'].toString())  : 0.0,
        totalSettleAmount: json['totalSettleAmount']!=null? double.parse(json['totalSettleAmount'].toString())  : 0.0,
        balance: json['balance']!=null? double.parse(json['balance'].toString())  : 0.0,
        total: json['total']!=null? double.parse(json['total'].toString())  : 0.0,
        address: json["address"],
        v: json["__v"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "phoneNumber": phoneNumber,
        "_id": id,
        'type': type,
        'guardianName': guardianName,
        "createdAt": createdAt?.toIso8601String(),
        "modeOfPayment": modeOfPayment,
        "amount": total,
        "total": total,
        "address": address,
        "balance": balance,
        "__v": v,
      };
}
