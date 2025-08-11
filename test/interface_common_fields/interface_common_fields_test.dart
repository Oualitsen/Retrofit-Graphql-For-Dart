import 'dart:io';

import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';
import 'package:retrofit_graphql/src/serializers/graphq_serializer.dart';
import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

final GQGrammar g = GQGrammar();

void main() async {
  test("common interface fields 1", () {
    final text = File("test/interface_common_fields/interface_common_fields_test.graphql").readAsStringSync();
    final GQGrammar g = GQGrammar(generateAllFieldsFragments: true);

    var parsed = g.parse(text);
    expect(parsed is Success, true);
    var basicEntityInterface = g.projectedTypes["BasicEntity"]!;
    var serializer = DartSerializer(g);

    print(serializer.serializeTypeDefinition(basicEntityInterface));
    expect(basicEntityInterface.fieldNames.length, 1);
    expect(basicEntityInterface.fieldNames, containsAll(["id"]));
    expect(basicEntityInterface.implementations.length, 2);
  });

  test("common interface fields 3", () {
    final text = File("test/interface_common_fields/interface_common_fields_test3.graphql").readAsStringSync();
    final GQGrammar g = GQGrammar(generateAllFieldsFragments: true);

    var parsed = g.parse(text);
    expect(parsed is Success, true);
    var basicEntityInterface = g.projectedTypes["BasicEntity"]!;
    var serializer = DartSerializer(g);

    print(serializer.serializeTypeDefinition(basicEntityInterface));
  });

  test("common interface fields 2", () {
    final text = File("test/interface_common_fields/interface_common_fields_test2.graphql").readAsStringSync();
    final GQGrammar g = GQGrammar(autoGenerateQueries: true, generateAllFieldsFragments: true);

    var parsed = g.parse(text);
    expect(parsed is Success, true);
    var basicEntityInterface = g.projectedTypes["BasicEntity"]!;
    var serializer = DartSerializer(g);

    var gqlSerial = GraphqSerializer(g);

    print(serializer.serializeTypeDefinition(basicEntityInterface));
    expect(basicEntityInterface.fieldNames.length, 3);

    expect(basicEntityInterface.fieldNames, containsAll(["id", "createdBy", "creationDate"]));
  });

  test("common interface (union) fields 1", () {
    final text = File("test/interface_common_fields/interface_common_fields_union_test.graphql").readAsStringSync();
    final GQGrammar g = GQGrammar();

    var parsed = g.parse(text);

    expect(parsed is Success, true);
    var vehicle = g.projectedTypes["Vehicle"]!;
    print("impl2 = ${vehicle.implementations.map((e) => e.token).toList()}");
    var serializer = DartSerializer(g);
    print(serializer.serializeTypeDefinition(vehicle));
    expect(vehicle.fieldNames.length, 2);
    expect(vehicle.fieldNames, containsAll(["make", "model"]));
    expect(vehicle.implementations.length, 2);
  });

  test("common interface (union) fields 2", () {
    final text = File("test/interface_common_fields/interface_common_fields_union_test2.graphql").readAsStringSync();
    final GQGrammar g = GQGrammar(autoGenerateQueries: true, generateAllFieldsFragments: true);
    var parsed = g.parse(text);
    expect(parsed is Success, true);
    var vehicle = g.projectedTypes["Vehicle"]!;
    var serializer = DartSerializer(g);
    print(serializer.serializeTypeDefinition(vehicle));
    expect(vehicle.fieldNames.length, 2);
    expect(vehicle.fieldNames, containsAll(["make", "model"]));
    print("vehicle.implementations = ${vehicle.implementations.map((e) => e.token)}");

    expect(vehicle.implementations.length, 2);
  });
}
