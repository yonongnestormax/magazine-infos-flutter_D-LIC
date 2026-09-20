import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modele/redacteur.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._interne();
  static Database? _database;

  // Singleton : une seule instance de DatabaseManager dans toute l'application
  factory DatabaseManager() {
    return _instance;
  }

  DatabaseManager._interne();

  // Récupère la base existante, ou l'initialise si elle n'existe pas encore
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initialisation();
    return _database!;
  }

  // Initialise la base de données SQLite et crée la table redacteurs
  Future<Database> initialisation() async {
    String chemin = join(await getDatabasesPath(), 'redacteurs.db');

    return await openDatabase(
      chemin,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE redacteurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT
          )
        ''');
      },
    );
  }

  // Récupère tous les rédacteurs enregistrés
  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('redacteurs');

    return List.generate(maps.length, (i) {
      return Redacteur.fromMap(maps[i]);
    });
  }

  // Insère un nouveau rédacteur (sans id, il sera généré automatiquement)
  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.insert(
      'redacteurs',
      redacteur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Met à jour un rédacteur existant (identifié par son id)
  Future<int> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  // Supprime un rédacteur par son id
  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return await db.delete(
      'redacteurs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}