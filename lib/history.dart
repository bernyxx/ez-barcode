import 'package:ez_barcode/barcodes.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> _groups = [];

  Future<void> initialize() async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), 'barcodes.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE barcodes (time TEXT PRIMARY KEY, main TEXT NOT NULL, data TEXT NOT NULL)',
        );
      },
      version: 1,
    );

    List<Map<String, dynamic>> data = await db
        .query('barcodes', groupBy: 'main', columns: ['main', 'count(main)']);

    setState(() {
      _groups = data.reversed.toList();
    });
  }

  void onItemTap(BuildContext ctx, String main) async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), 'barcodes.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE barcodes (time TEXT PRIMARY KEY, main TEXT NOT NULL, data TEXT NOT NULL)',
        );
      },
      version: 1,
    );

    List<Map<String, dynamic>> data = await db.query(
      'barcodes',
      where: 'main = ?',
      whereArgs: [main],
    );

    // ignore: use_build_context_synchronously
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) {
          return Barcodes(data);
        },
      ),
    );
  }

  void deleteGroup(String mainID) async {
    Database db = await openDatabase(
      join(await getDatabasesPath(), 'barcodes.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE barcodes (time TEXT PRIMARY KEY, main TEXT NOT NULL, data TEXT NOT NULL)',
        );
      },
      version: 1,
    );
    await db.delete('barcodes', where: 'main = ?', whereArgs: [mainID]);

    setState(() {
      _groups.removeWhere((element) => element["main"] == mainID);
    });
  }

  void clearDB(BuildContext ctx) async {
    showDialog(
      barrierDismissible: false,
      context: ctx,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conferma'),
          content: const Text(
              'Vuoi veramente eliminare la cronologia delle scansioni?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                Database db = await openDatabase(
                  join(await getDatabasesPath(), 'barcodes.db'),
                  onCreate: (db, version) async {
                    await db.execute(
                      'CREATE TABLE barcodes (time TEXT PRIMARY KEY, main TEXT NOT NULL, data TEXT NOT NULL)',
                    );
                  },
                  version: 1,
                );
                await db.rawDelete('DELETE FROM barcodes');

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                setState(() {
                  _groups.clear();
                });
              },
              child: const Text('SÌ'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              'Cronologia',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                DateTime dt = DateTime.parse(_groups[index]['main']);
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => deleteGroup(_groups[index]["main"]),
                  background: Container(
                    color: Colors.red,
                    margin: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.delete),
                        SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                  ),
                  key: Key(dt.toString()),
                  child: InkWell(
                    onTap: () => onItemTap(context, _groups[index]['main']),
                    child: Card(
                      child: ListTile(
                        title: Text('${_groups[index]['count(main)']} codici'),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm:ss')
                              .format(dt)
                              .toString(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _groups.isNotEmpty ? () => clearDB(context) : null,
            child: const Text('Cancella Cronologia'),
          ),
        ],
      ),
    );
  }
}
