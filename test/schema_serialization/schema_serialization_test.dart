import 'dart:io';

import 'package:petitparser/petitparser.dart';
import 'package:retrofit_graphql/src/serializers/graphq_serializer.dart';
import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';

final GQGrammar g = GQGrammar();

void main() {
  const fileName = "test/schema_serialization/schema.graphql";
  test("schema generation", () async {
    
    final g = GQGrammar(generateAllFieldsFragments: true);
     var result = await  g.parseFile(fileName);
     expect(result is Success, true);
     final serializer = GraphqSerializer(g);
    var schema = serializer.generateSchema();
    var file = File(fileName + ".graphql");
    file.writeAsString(schema);
   
  });

}
