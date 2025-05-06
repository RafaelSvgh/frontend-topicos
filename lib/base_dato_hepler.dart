import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

var path = '';

class BaseDatoHepler {
  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    path = join(databasePath, 'asistente_legal.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE usuarios(id INTEGER PRIMARY KEY, name TEXT)
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertUsuario(String name) async {
    final db = await _openDatabase();
    await db.insert(
      'usuarios',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Usuario insertado: $name');
    await db.close();
  }

  Future<void> mostrarUsuarios() async {
    final db = await _openDatabase();
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    for (var map in maps) {
      print('ID: ${map['id']}, Name: ${map['name']}');
    }
    await db.close();
  }
}
