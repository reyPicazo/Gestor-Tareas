import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:gestor_tareas_local/models/tarea.dart';

part 'app_database.g.dart';

@UseRowClass(Tarea)
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1)();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'gestor_tareas_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  Stream<List<Tarea>> observarTareas() => select(tareas).watch();

  Future<int> agregarTarea(String titulo) {
    final limpio = titulo.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('Pon algo en titullo');
    }
    return into(tareas).insert(TareasCompanion.insert(titulo: limpio));
  }

  Future<bool> editarTitulo(int id, String nuevoTitulo) async {
    final limpio = nuevoTitulo.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('Pon algo en titullo');
    }
    final filas = await (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(titulo: Value(limpio)));
    return filas > 0;
  }

  Future<bool> actualizarEstado(int id, bool completada) async {
    final filas = await (update(tareas)..where((t) => t.id.equals(id)))
        .write(TareasCompanion(completada: Value(completada)));
    return filas > 0;
  }

  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }
}