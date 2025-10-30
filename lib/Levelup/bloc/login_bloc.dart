import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<RememberToggleEvent>((event, emit) {
      emit(RememberState(value: event.value));
    });
    on<ShowPassToggleEvent>((event, emit) {
      emit(ShowPassState(value: event.value));
    });
    on<ShowTipEvent>((event, emit) {
      emit(ShowTipState(showTip: !event.showTip));
    });

    on<ChangeSelectedDateEvent>((event, emit) {
      emit(ChangeSelectedDateTimeState(selectedDate: event.selectedTime));
    });
    on<ChangeAvatarEvent>((event, emit) {
      emit(ChangeAvatarState(imageurl: event.avatarurl));
    });

    on<IncompleteProfileNavigationEvent>((event, emit) {
      emit(IncompleteProfileNavigationState());
    });
  }
}
