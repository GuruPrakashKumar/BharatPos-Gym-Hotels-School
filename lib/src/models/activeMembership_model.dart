
import 'package:shopos/src/models/membershipPlan_model.dart';

class ActiveMembershipModel{
  ActiveMembershipModel({
    this.user,
    this.party,
    this.membership,
    this.lastPaid,
    this.validity,
    this.due,
    this.createdAt,
    this.id,
    this.activeStatus
  });
  String? id;
  String? user;
  String? party;
  MembershipPlanModel? membership;
  DateTime? lastPaid;
  int? validity;
  double? due;
  DateTime? createdAt;
  bool? activeStatus;

  Map<String, dynamic> toMap(){
    return{
      "id": id,
      "user": user,
      "party": party,
      "validity": validity,
      "membership": membership,
      "lastPaid": lastPaid.toString(),
      "due": due,
      "createdAt": createdAt,
      "activeStatus": activeStatus
    };
  }
  factory ActiveMembershipModel.fromMap(map){
    print("in from map of active membership and last paid is ${map['lastPaid']}");
    print("in from map of active membership and last paid is ${DateTime.parse(map['createdAt'])}");
    return ActiveMembershipModel(
      id: map['_id'],
      user: map['user']['_id'],
      party: map['party']['_id'],
      validity: map['validity'],
      membership: MembershipPlanModel.fromMap(map['membership']),
      lastPaid: DateTime.parse(map['lastPaid']),
      due: map['due'].toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      activeStatus: map['activeStatus']
    );
  }
}