import 'package:retrofit_graphql/src/config.dart';
import 'package:retrofit_graphql/src/main.dart';
import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';
import 'package:retrofit_graphql/src/serializers/flutter_type_widget_serializer.dart';
import 'package:retrofit_graphql/src/serializers/language.dart';
import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

const outputDir = "../my_web_app/lib/generated";

void main() {
  test("Fragment value test", () async {
    var g = GQGrammar(
        autoGenerateQueries: true,
        mode: CodeGenerationMode.client,
        generateAllFieldsFragments: true);
    var result = g.parse('''
  enum Gender {male, female}
  type Person {
    name: String!
    middleName: String
    gender: Gender!
    age: Int!
  }

  type Query {
    getPerson: Person
  }

''');

    expect(result is Success, true);
    var type = g.types["Person"]!;
    var dartSerialzer = DartSerializer(g);
    var serial = FlutterTypeWidgetSerializer(g, dartSerialzer, false);
    var typeSerial = serial.serializeType(type);

    var buffer = StringBuffer();

    await generateClientClasses(
        g,
        GeneratorConfig(
            schemaPaths: [],
            mode: g.mode.name,
            identityFields: [],
            typeMappings: g.typeMap,
            outputDir: outputDir,
            clientConfig: ClientConfig(
                targetLanguage: "dart",
                generateAllFieldsFragments: g.generateAllFieldsFragments,
                nullableFieldsRequired: false,
                autoGenerateQueries: g.autoGenerateQueries,
                operationNameAsParameter: false,
                packageName: "my_web_app")),
        DateTime.now(), pack: 'lib/generated');
  });
}
