import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instanew/Screens/postWidget.dart';

import '../domain/FeedBloc/feedsBloc.dart';
import '../domain/FeedBloc/feedsEvents.dart';
import '../domain/FeedBloc/feedsSate.dart';


class feeds extends StatefulWidget{
  createState() => feedsState();
}

class feedsState extends State<feeds>{
  var feedbloc = feedsblocs();

  @override
  void initState() {
    // TODO: implement initState
   Future.delayed(Duration(seconds: 2),(){
     feedbloc.add(callapi());
   });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<feedsblocs,feedsblocState>(
        bloc: feedbloc,
          builder:(context, state){
          if(state is feedsdLoading){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            return PageView.builder(
              itemCount: 12,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, ind) {
                return PostWidget();
              },
            );
          }
          }, listener:(context, state){

      }),
    );
  }

}