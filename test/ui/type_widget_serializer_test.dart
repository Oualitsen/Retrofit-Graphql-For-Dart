import 'package:retrofit_graphql/src/config.dart';
import 'package:retrofit_graphql/src/main.dart';
import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';
import 'package:retrofit_graphql/src/serializers/flutter_type_widget_serializer.dart';
import 'package:retrofit_graphql/src/serializers/language.dart';
import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

const outputDir = "../my_web_app/lib/generated";

getConfig(GQGrammar g) {
  return GeneratorConfig(
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
          packageName: "my_web_app"));
}

void main() {
  test("UI View gen", () async {
    var g = GQGrammar(
        autoGenerateQueries: true,
        mode: CodeGenerationMode.client,
        generateAllFieldsFragments: true);
    var result = g.parse('''
  type SingleLabelData {
    name: String!
  }

  type Query {
    getSingleLabelData: SingleLabelData
  }

''');

    expect(result is Success, true);
    await generateClientClasses(g, getConfig(g), DateTime.now(),
        pack: 'lib/generated');
  });


  test("UI View gen enum", () async {
    var g = GQGrammar(
        autoGenerateQueries: true,
        mode: CodeGenerationMode.client,
        generateAllFieldsFragments: true);
    var result = g.parse('''
enum Gender {male, female}
  type WidgetEnumValue {
    gender: Gender
  }

  type Query {
    getSingleLabelData: WidgetEnumValue
  }

''');

    expect(result is Success, true);
    await generateClientClasses(g, getConfig(g), DateTime.now(),
        pack: 'lib/generated');
  });


  test("UI View gen nullable", () async {
    var g = GQGrammar(
        autoGenerateQueries: true,
        mode: CodeGenerationMode.client,
        generateAllFieldsFragments: true);
    var result = g.parse('''
  type SingleLabelDataNullable {
    name: String
  }

  type Query {
    getSingleLabelData: SingleLabelDataNullable
  }

''');

    expect(result is Success, true);
    await generateClientClasses(g, getConfig(g), DateTime.now(),
        pack: 'lib/generated');
  });
}
