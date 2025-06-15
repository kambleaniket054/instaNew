// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//
// import '../model/OverlayItem.dart';
//
//
// class TextEditorDialog extends StatefulWidget {
//   final OverlayItem overlay;
//   final Function(OverlayItem) onSave;
//
//   TextEditorDialog({required this.overlay, required this.onSave});
//
//   @override
//   _TextEditorDialogState createState() => _TextEditorDialogState();
// }
//
// class _TextEditorDialogState extends State<TextEditorDialog> {
//   late TextEditingController _controller;
//   double _fontSize = 20.0;
//   Color _color = Colors.white;
//   bool _hasBorder = false;
//   FontStyle _fontStyle = FontStyle.normal;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.overlay.content);
//     _fontSize = widget.overlay.fontSize;
//     _color = widget.overlay.color;
//     _hasBorder = widget.overlay.hasBorder;
//     _fontStyle = widget.overlay.fontStyle;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Edit Text'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(labelText: 'Text'),
//           ),
//           Slider(
//             value: _fontSize,
//             min: 10,
//             max: 50,
//             onChanged: (value) => setState(() => _fontSize = value),
//             label: 'Font Size: ${_fontSize.round()}',
//           ),
//           Row(
//             children: [
//               Text('Color:'),
//               SizedBox(width: 10),
//               GestureDetector(
//                 onTap: () async {
//                   Color? picked = await showColorPicker(context);
//                   if (picked != null) setState(() => _color = picked);
//                 },
//                 child: Container(width: 30, height: 30, color: _color),
//               ),
//             ],
//           ),
//           CheckboxListTile(
//             title: Text('Border'),
//             value: _hasBorder,
//             onChanged: (value) => setState(() => _hasBorder = value!),
//           ),
//           DropdownButton<FontStyle>(
//             value: _fontStyle,
//             items: [FontStyle.normal, FontStyle.italic]
//                 .map((style) => DropdownMenuItem(
//               value: style,
//               child: Text(style == FontStyle.normal ? 'Normal' : 'Italic'),
//             ))
//                 .toList(),
//             onChanged: (value) => setState(() => _fontStyle = value!),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             widget.overlay.content = _controller.text;
//             widget.overlay.fontSize = _fontSize;
//             widget.overlay.color = _color;
//             widget.overlay.hasBorder = _hasBorder;
//             widget.overlay.fontStyle = _fontStyle;
//             widget.onSave(widget.overlay);
//             Navigator.pop(context);
//           },
//           child: Text('Save'),
//         ),
//       ],
//     );
//   }
//
//   Future<Color?> showColorPicker(BuildContext context) async {
//     return showDialog<Color>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Pick a color'),
//         content: SingleChildScrollView(
//           child: MaterialPicker(
//             pickerColor: _color,
//             onColorChanged: (color) => setState(() => _color = color),
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Select'),
//             onPressed: () => Navigator.pop(context, _color),
//           ),
//         ],
//       ),
//     );
//   }
// }