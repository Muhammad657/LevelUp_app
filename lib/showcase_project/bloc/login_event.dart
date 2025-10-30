part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class RememberToggleEvent extends LoginEvent {
  final bool value;
  RememberToggleEvent({required this.value});
}

class ShowPassToggleEvent extends LoginEvent {
  final bool value;
  ShowPassToggleEvent({required this.value});
}

class ShowTipEvent extends LoginEvent {
  final bool showTip;
  ShowTipEvent({required this.showTip});
}

class ChangeSelectedDateEvent extends LoginEvent {
  final DateTime selectedTime;
  ChangeSelectedDateEvent({required this.selectedTime});
}

class ChangeAvatarEvent extends LoginEvent {
  final String avatarurl;

  ChangeAvatarEvent({required this.avatarurl});
}


class IncompleteProfileNavigationEvent extends LoginEvent{
  
}