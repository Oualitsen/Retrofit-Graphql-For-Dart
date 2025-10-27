import 'package:retrofit_graphql/src/config.dart';
import 'package:retrofit_graphql/src/main.dart';
import 'package:retrofit_graphql/src/model/built_in_dirctive_definitions.dart';
import 'package:retrofit_graphql/src/serializers/language.dart';
import 'package:retrofit_graphql/src/utils.dart';
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
          appLocalizationsImport: 'package:my_web_app/generated/i18n/app_localizations.dart',
          targetLanguage: "dart",
          generateAllFieldsFragments: g.generateAllFieldsFragments,
          nullableFieldsRequired: false,
          autoGenerateQueries: g.autoGenerateQueries,
          operationNameAsParameter: false,
          generateUiInputs: true,
          generateUiTypes: true,
          packageName: "my_web_app"));
}

void main() {
  test("UI input gen", () async {
    var g = GQGrammar(autoGenerateQueries: true, mode: CodeGenerationMode.client, generateAllFieldsFragments: true);
    var result = g.parse('''
  input SingleFieldInput {
    name: String!
  }
''');

    expect(result is Success, true);
    await generateClientClasses(g, getConfig(g), DateTime.now(), pack: 'lib/generated');
  });

  
}
