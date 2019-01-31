import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/model/database.dart';
import 'package:floor_generator/model/entity.dart';
import 'package:floor_generator/model/query_method.dart';
import 'package:floor_generator/writer/query_method_writer.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';

/// Takes care of generating the database implementation.
class DatabaseWriter implements Writer {
  final LibraryReader library;

  DatabaseWriter(this.library);

  @override
  Spec write() {
    final database = _getDatabase();

    return Library((builder) => builder
      ..body.addAll([
        _generateOpenDatabaseFunction(database.name),
        _generateDatabaseImplementation(database)
      ]));
  }

  Database _getDatabase() {
    final databaseClasses = library.classes.where((clazz) =>
        clazz.isAbstract && clazz.metadata.any(isDatabaseAnnotation));

    if (databaseClasses.isEmpty) {
      throw InvalidGenerationSourceError(
          'No database defined. Add a @Database annotation to your abstract database class.');
    } else if (databaseClasses.length > 1) {
      throw InvalidGenerationSourceError(
          'Only one database is allowed. There are too many classes annotated with @Database.');
    } else {
      return Database(databaseClasses.first);
    }
  }

  Method _generateOpenDatabaseFunction(String databaseName) {
    return Method((builder) => builder
      ..returns = refer('Future<$databaseName>')
      ..name = '_\$open'
      ..modifier = MethodModifier.async
      ..body = Code('''
            final database = _\$$databaseName();
            database.database = await database.open();
            return database;
            '''));
  }

  Class _generateDatabaseImplementation(Database database) {
    final createTableStatements =
        _generateCreateTableSqlStatements(database.getEntities(library))
            .map((statement) => 'await database.execute($statement);')
            .join('\n');

    if (createTableStatements.isEmpty) {
      throw InvalidGenerationSourceError(
          'There are no entities defined. Use the @Entity annotation on model classes to do so.');
    }

    final databaseName = database.name;

    return Class(
      (builder) => builder
        ..name = '_\$$databaseName'
        ..extend = refer(databaseName)
        ..methods.add(
          Method((builder) => builder
            ..name = 'open'
            ..annotations.add(AnnotationExpression('override'))
            ..returns = refer('Future<sqflite.Database>')
            ..modifier = MethodModifier.async
            ..body = Code('''
            final path = join(await sqflite.getDatabasesPath(), '${databaseName.toLowerCase()}.db');

            return await sqflite.openDatabase(
              path,
              onCreate: (database, version) async {
                $createTableStatements
              },
            );
            ''')),
        )
        ..methods.addAll(_generateQueryMethods(database.queryMethods)),
    );
  }

  List<Method> _generateQueryMethods(List<QueryMethod> queryMethods) {
    return queryMethods
        .map((queryMethod) => QueryMethodWriter(library, queryMethod).write())
        .toList();
  }

  List<String> _generateCreateTableSqlStatements(List<Entity> entities) {
    return entities.map(_generateSql).toList();
  }

  String _generateSql(Entity entity) {
    final columns = entity.columns.map((column) {
      var columnString = '${column.name} ${column.type}';

      final additionals = column.additionals;
      if (additionals != null) {
        columnString += additionals;
      }
      return columnString;
    }).join(', ');

    return "'CREATE TABLE IF NOT EXISTS ${entity.name} ($columns)'";
  }
}