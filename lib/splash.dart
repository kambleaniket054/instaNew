import 'package:flutter/material.dart';

class splash extends StatefulWidget{
  Color color;
  splash(this.color);
  createState() => splashstate();
}

class splashstate extends State<splash>{
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: widget.color,
     body: Center(
       child: Container(
         child: Text("Wellcome to splash Screen",style: TextStyle(fontSize: 12,color: Colors.black45),),
       ),
     ),
   );
  }
  
}