import 'dart:io';

import 'package:retrofit_graphql/src/extensions.dart';
import 'package:retrofit_graphql/src/serializers/dart_client_serializer.dart';
import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';
import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() async {
  void generateGraphqlFile(int size) {
    var buffer = StringBuffer();
    var template = '''
  type Person {
    name: String!
    lastName: String!
    age: Int!
}''';

    for (int i = 0; i < size; i++) {
      buffer.writeln(template.replaceFirst('type Person', 'type Person${i}'));
    }
    buffer.writeln("type Query {");

    for (int i = 0; i < size; i++) {
      buffer.writeln('getPerson${i}: Person${i}!'.ident());
    }
    buffer.writeln("}");

    buffer.write("type Mutation {");

    for (int i = 0; i < size; i++) {
      buffer.writeln('createPerson${i}: Person${i}!'.ident());
    }
    buffer.writeln("}");

    var file = File('test/perfs/perfs_test.graphql');
    file.writeAsStringSync(buffer.toString());
  }

  test("genFile", () {
    generateGraphqlFile(10);
  });

  test("perfs test 1", () async {
    var values = [10, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000];
    values = [500];
    for (var size in values) {

      generateGraphqlFile(size);
      final GQGrammar g = GQGrammar(
          generateAllFieldsFragments: true, autoGenerateQueries: true);
          var serial = DartSerializer(g);
          var clientGen = DartClientSerializer(g, serial);
      var text = File('test/perfs/perfs_test.graphql').readAsStringSync();
      var start = DateTime.now();
      g.parse(text);
      // g.types.values.forEach((def) {
      //   serial.serializeTypeDefinition(def, "prefix");
      // });
      // clientGen.generateClient('prefix');
      var end = DateTime.now();

      var delta = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print("{'s': ${delta.toDouble()/1000}, 'count': ${size}}");
    }
  });
}
