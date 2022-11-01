import 'package:flutter/material.dart';
import 'package:ez_barcode/display_widget.dart';

class Barcodes extends StatelessWidget {
  final List<Map<String, dynamic>> barcodes;

  const Barcodes(this.barcodes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizzazione Codici'),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: barcodes.length,
                itemBuilder: (context, index) {
                  return DisplayWidget(
                    barcodes[index]['data']!,
                    key: Key(barcodes[index]['time']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
