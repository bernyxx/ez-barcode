import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class DisplayWidget extends StatefulWidget {
  final String data;

  const DisplayWidget(this.data, {super.key});

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  String data = "";
  bool _isHidden = false;

  void switchVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.length == 12) {
      data = "0${widget.data}";
    } else {
      data = widget.data;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: BarcodeWidget(
              data: data,
              barcode: Barcode.ean13(),
              color: _isHidden ? Colors.grey[200]! : Colors.black,
              style: TextStyle(
                color: _isHidden ? Colors.grey[200]! : Colors.black,
              ),
            ),
          ),
          IconButton(
            onPressed: switchVisibility,
            icon: Icon(_isHidden ? Icons.visibility : Icons.visibility_off),
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }
}
