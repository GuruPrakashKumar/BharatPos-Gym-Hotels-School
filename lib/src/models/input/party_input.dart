class PartyInput {
  PartyInput({
    this.id,
    this.name,
    this.phoneNumber,
    this.address,
    required this.type,
    this.guardianName
  });
  String? id;
  String? name;
  String? phoneNumber;
  String? address;
  String type;
  String? guardianName;

  factory PartyInput.fromMap(Map<String, dynamic> json) => PartyInput(
      name: json["name"],
      phoneNumber: json["phoneNumber"],
      address: json["address"],
      id: json["_id"],
      guardianName: json["guardianName"],
      type: json['type']);

  Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
        "type": type,
        "phoneNumber": phoneNumber,
        "guardianName": guardianName,
        "address": address,
      };
}
