import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/main.dart';
import 'package:drift/native.dart';
import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:gestor_tareas_local/models/tarea.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    await tester.pumpWidget(const GestorTareasApp());
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Rechazar titulos vacios', () async {
    expect(() => db.agregarTarea(''), throwsArgumentError);
    expect(() => db.agregarTarea('    '), throwsArgumentError);
  });

  test('TRabajar con una tarea', () async {
    final id = await db.agregarTarea('Estudiar SQLite');
    List<Tarea> lista = await db.observarTareas().first;

    expect(lista.length, 1);
    expect(lista.first.id, id);
    expect(lista.first.titulo, 'Tarea 1');
    expect(lista.first.completada, false);

    await db.actualizarEstado(id, true);
    await db.editarTitulo(id, 'Tarea 1 editada');
    lista = await db.observarTareas().first;

    expect(lista.first.titulo, 'Tarea 1 editada');
    expect(lista.first.completada, true);
  });

  test('Eliminar tarea', () async {
    final id2 = await db.agregarTarea('Tarea 2');
    final id3 = await db.agregarTarea('Tarea 3');

    await db.eliminarTarea(id2);
    final lista = await db.observarTareas().first;

    expect(lista.length, 1);
    expect(lista.first.id, id3);
  });
}