part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

class RememberState extends LoginState {
  final bool value;
  RememberState({required this.value});
}

class ShowPassState extends LoginState {
  final bool value;
  ShowPassState({required this.value});
}

class ShowTipState extends LoginState {
  final bool showTip;
  ShowTipState({required this.showTip});
}

class ChangeSelectedDateTimeState extends LoginState {
  final DateTime selectedDate;

  ChangeSelectedDateTimeState({required this.selectedDate});
}

class ChangeAvatarState extends LoginState {
  final String imageurl;

  ChangeAvatarState({required this.imageurl});
}



class IncompleteProfileNavigationState extends LoginState{
  
}