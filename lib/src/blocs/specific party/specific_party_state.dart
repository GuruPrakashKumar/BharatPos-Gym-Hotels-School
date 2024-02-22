import 'package:shopos/src/models/activeMembership_model.dart';
import 'package:shopos/src/models/input/order.dart';

import 'package:shopos/src/models/party.dart';

abstract class SpecificPartyState {}

class SpecificPartyInitial extends SpecificPartyState {}

class SpecificPartyListRender extends SpecificPartyState {
  final List<ActiveMembershipModel> activeMemberships;
  SpecificPartyListRender({
    required this.activeMemberships,
  });
}

class SpecificPartyLoading extends SpecificPartyState {}

class SpecificPartyError extends SpecificPartyState {
  late final String message;
  SpecificPartyError(this.message);
}

class SpecificPartySuccess extends SpecificPartyState {}

class DeletePartyState extends SpecificPartyState {}
