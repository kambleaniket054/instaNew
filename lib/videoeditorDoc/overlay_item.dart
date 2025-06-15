// // import 'package:flutter/material.dart';
// //
// // class OverlayItem {
// //   final String type;
// //   String content;
// //   Offset position;
// //   double startTime;
// //   double duration;
// //   double fontSize;
// //   Color color;
// //   bool hasBorder;
// //   FontStyle fontStyle;
// //
// //   OverlayItem({
// //     required this.type,
// //     required this.content,
// //     required this.position,
// //     required this.startTime,
// //     required this.duration,
// //     this.fontSize = 20.0,
// //     this.color = Colors.white,
// //     this.hasBorder = false,
// //     this.fontStyle = FontStyle.normal,
// //   });
// // }
//
// import 'package:flutter/material.dart';
//
// class OverlayItem {
//    String type;
//    String content;
//    Offset position;
//    double startTime;
//    double duration;
//    double scale; // Added for resizing
//    double previewWidth; // Added for accurate positioning
//    double previewHeight;
//   // Text-specific fields
//    double fontSize;
//    Color color;
//    bool hasBorder;
//    FontStyle fontStyle;
//
//   OverlayItem({
//     required this.type,
//     required this.content,
//     required this.position,
//     required this.startTime,
//     required this.duration,
//     this.scale = 1.0,
//     this.previewWidth = 720,
//     this.previewHeight = 1280,
//     this.fontSize = 24,
//     this.color = Colors.white,
//     this.hasBorder = false,
//     this.fontStyle = FontStyle.normal,
//   });
//
//   OverlayItem copyWith({
//     String? type,
//     String? content,
//     Offset? position,
//     double? startTime,
//     double? duration,
//     double? scale,
//     double? previewWidth,
//     double? previewHeight,
//     double? fontSize,
//     Color? color,
//     bool? hasBorder,
//     FontStyle? fontStyle,
//   }) {
//     return OverlayItem(
//       type: type ?? this.type,
//       content: content ?? this.content,
//       position: position ?? this.position,
//       startTime: startTime ?? this.startTime,
//       duration: duration ?? this.duration,
//       scale: scale ?? this.scale,
//       previewWidth: previewWidth ?? this.previewWidth,
//       previewHeight: previewHeight ?? this.previewHeight,
//       fontSize: fontSize ?? this.fontSize,
//       color: color ?? this.color,
//       hasBorder: hasBorder ?? this.hasBorder,
//       fontStyle: fontStyle ?? this.fontStyle,
//     );
//   }
// }