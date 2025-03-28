import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instanew/splash.dart';

class MyRoutes{
  static const initialRoute = "/";
  static const splash = "/splash";
}

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings){
    var name  = settings.name;
    switch(name){
      case MyRoutes.initialRoute:
        return MaterialPageRoute(
            builder: (BuildContext context) => splash(Colors.white),
            maintainState: false,
            settings: settings);
      default:
        return MaterialPageRoute(
            builder: (BuildContext context) => splash(Colors.white),
            maintainState: false,
            settings: settings);
    }
  }
}