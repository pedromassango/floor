import 'misc/string_utils_test.dart' as string_utils_test;
import 'misc/type_utils_test.dart' as type_utils_test;
import 'processor/database_processor_test.dart' as database_processor_test;
import 'processor/entity_processor_test.dart' as entity_processor_test;
import 'processor/field_processor_test.dart' as field_processor_test;
import 'processor/query_method_processor_test.dart' as query_processor_test;
import 'processor/transaction_method_processor_test.dart'
    as transaction_method_processor_test;
import 'value_object/index_test.dart' as index_test;
import 'writer/dao_writer_test.dart' as dao_writer_test;
import 'writer/database_builder_writer_test.dart'
    as database_builder_writer_test;
import 'writer/database_writer_test.dart' as database_writer_test;
import 'writer/deletion_method_writer_test.dart' as deletion_method_writer_test;
import 'writer/floor_writer_test.dart' as floor_writer_test;
import 'writer/insert_method_writer_test.dart' as insert_method_writer_test;
import 'writer/query_method_writer_test.dart' as query_method_writer_test;
import 'writer/update_method_writer_test.dart' as update_method_writer_test;

void main() {
  // Misc
  string_utils_test.main();
  type_utils_test.main();

  // Processor
  database_processor_test.main();
  field_processor_test.main();
  entity_processor_test.main();
  query_processor_test.main();
  transaction_method_processor_test.main();

  // Value object
  index_test.main();

  // Writer
  dao_writer_test.main();
  database_builder_writer_test.main();
  database_writer_test.main();
  deletion_method_writer_test.main();
  floor_writer_test.main();
  insert_method_writer_test.main();
  query_method_writer_test.main();
  update_method_writer_test.main();
}
