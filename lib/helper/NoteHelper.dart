import 'package:my_notes/model/Note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NoteHelper {

  static final String tableName = "note";
  static final NoteHelper _noteHelper = NoteHelper._internal();

  Database _db;

  factory NoteHelper() {
    return _noteHelper;
  }

  NoteHelper._internal() {}

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE note ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "title VARCHAR, "
        "description TEXT, "
        "date DATETIME)";
    await db.execute(sql);
  }

  initDB() async {
    final databasePath = await getDatabasesPath();
    final databaseLocal = join(databasePath, "my_notes.db");

    var db = await openDatabase(databaseLocal, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> saveNote(Note note) async {
    var database = await db;

    int result = await database.insert(tableName, note.toMap());
    return result;
  }

  getNotes() async {
    var database = await db;
    String sql = "SELECT * FROM $tableName ORDER BY date DESC";
    List notes = await database.rawQuery(sql);
    return notes;
  }

  Future<int> updateNote(Note note) async {
    var database = await db;
    int result = await database.update(
      tableName,
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id]
    );
    return result;
  }

  Future<int> removeNote(int id) async {
    var database = await db;
    int result = await database.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id]
    );
    return result;
  }

}