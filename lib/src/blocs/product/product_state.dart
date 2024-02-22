part of 'product_cubit.dart';

@immutable
abstract class MembershipState {}

class MembershipInitial extends MembershipState {}

class MembershipListRender extends MembershipState {
  final List<MembershipPlanModel> memberships;
  MembershipListRender(this.memberships);
}

class MembershipLoading extends MembershipState {}

class MembershipCreated extends MembershipState {}

class MembershipCreationFailed extends MembershipState {}

class gstincludeoptionenable extends MembershipState {}

class calculateallgst extends MembershipState {}

class MembershipError extends MembershipState {
  final String message;
  MembershipError(this.message);
}
