import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'feedsEvents.dart';
import 'feedsSate.dart';

class feedsblocs extends Bloc<feedsEvents,feedsblocState>{
  feedsblocs(): super(feedsdLoading()){
    on<callapi>(_callapi);
  }
  FutureOr<void> _callapi(callapi event, Emitter<feedsblocState> emit) {
    emit(feedsdLoaded());
  }
}
