import 'package:ez_barcode/barcodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  List<Map<String, dynamic>> _barcodes = [];
  String id = '';

  Future<void> scanBarcode() async {
    String res = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancella',
      false,
      ScanMode.BARCODE,
    );

    Database db = await openDatabase(
      join(await getDatabasesPath(), 'barcodes.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE barcodes (time TEXT PRIMARY KEY, main TEXT NOT NULL, data TEXT NOT NULL)',
        );
      },
      version: 1,
    );

    if (res != '-1') {
      Map<String, String> newBarcode = {
        "time": DateTime.now().toString(),
        "main": id,
        "data": res
      };
      setState(() {
        _barcodes.add(newBarcode);
      });

      await db.insert('barcodes', newBarcode);
    }
  }

  void removeBarcode(Map<String, dynamic> barcode) async {
    setState(() {
      _barcodes.removeWhere((element) => element["time"] == barcode["time"]);
    });

    Database db = await openDatabase(
      join(await getDatabasesPath(), 'barcodes.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE barcodes (time TEXT PRIMARY KEY, main TEXT NOT NULL, data TEXT NOT NULL)',
        );
      },
      version: 1,
    );

    await db
        .delete('barcodes', where: 'time = ?', whereArgs: [barcode["time"]]);
  }

  void showBarcodes(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => Barcodes(_barcodes),
      ),
    );
  }

  void flushScanner() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(id)) {
      prefs.remove(id);
    }

    id = DateTime.now().toString();
    prefs.setString('id', id);

    setState(() {
      _barcodes.clear();
    });
  }

  void initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('id')) {
      id = prefs.getString('id')!;

      Database db = await openDatabase(
        join(await getDatabasesPath(), 'barcodes.db'),
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE barcodes (time TEXT PRIMARY KEY, main TEXT NOT NULL, data TEXT NOT NULL)',
          );
        },
        version: 1,
      );

      List<Map<String, dynamic>> oldBarcodes = await db.query(
        'barcodes',
        where: 'main = ?',
        whereArgs: [id],
      );

      setState(() {
        _barcodes = oldBarcodes.toList();
      });
    } else {
      id = DateTime.now().toString();
      prefs.setString('id', id);
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                'Lista di codici scansionati',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _barcodes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(5),
                    child: ListTile(
                      title: Text(_barcodes[index]['data']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => removeBarcode(_barcodes[index]),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: scanBarcode,
              child: const Text(
                'Scannerizza un nuovo codice',
              ),
            ),
            ElevatedButton(
              onPressed:
                  _barcodes.isNotEmpty ? () => showBarcodes(context) : null,
              child: const Text('Visualizza Codici'),
            ),
            ElevatedButton(
              onPressed: _barcodes.isNotEmpty ? () => flushScanner() : null,
              child: const Text('Nuovo Gruppo'),
            ),
          ],
        ),
      ),
    );
  }
}
