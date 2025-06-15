import 'package:flutter/material.dart';

class DraggableTimelineItem extends StatefulWidget {
  final String label;

  const DraggableTimelineItem({super.key, required this.label});

  @override
  _DraggableTimelineItemState createState() => _DraggableTimelineItemState();
}

class _DraggableTimelineItemState extends State<DraggableTimelineItem> {
  double position = 50.0;
  double width = 100.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          position += details.delta.dx;
        });
      },
      child: Stack(
        children: [
        Positioned(
        left: position,
        child: Container(
          width: width,
          height: 50,
          color: Colors.blue,
          child: Center(
            child: Text(widget.label, style: const TextStyle(color: Colors.black)),
          ),
        ),
      ),
   
      ],) );
  }
}
