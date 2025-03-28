import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instanew/domain/bottomNavigations/bottomNavigationEvent.dart';
import 'package:instanew/domain/bottomNavigations/bottomNavigationState.dart';

class bottomNavigationBloc extends Bloc<bottomnavigationevent,bottomnavigationstate>{
  bottomNavigationBloc() : super(navigationTabindex(tabindex: 0)){
    on<changebottomscreen>(_changebottomscreen);
  }


  FutureOr<void> _changebottomscreen(changebottomscreen event, Emitter<bottomnavigationstate> emit) {
   int tab = event.tabindex ?? 0;
   emit(navigationTabindex(tabindex: tab));
  }
}