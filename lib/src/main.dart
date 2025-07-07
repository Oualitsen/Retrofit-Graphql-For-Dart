import 'dart:io';

import 'package:retrofit_graphql/src/config.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/serializers/java_serializer.dart';
import 'package:retrofit_graphql/src/serializers/language.dart';
import 'package:petitparser/petitparser.dart';
import 'package:retrofit_graphql/src/serializers/spring_server_serializer.dart';
import 'package:args/args.dart';
import 'dart:convert';
const destinationDir =
    "C:/Users/Ramdane/Documents/Projects/Dentilynx/dentilynx-back/src/main/java/com/dentlynx/generated";
const packageName = "com.dentlynx.generated";
const graphqlFile =
    "C:/Users/Ramdane/Documents/Projects/Dentilynx/dentilynx-back/src/main/resources/graphql/schema.graphqls";




Future<void> main(List<String> arguments) async {

  final parser = ArgParser()
    ..addOption(
      'config',
      abbr: 'c',
      help: 'Path to the config file',
      defaultsTo: 'graphql_codegen.json',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    );

  final args = parser.parse(arguments);

  if (args['help'] as bool) {
    print('''
Usage: graphql_codegen generate [options]

Options:
${parser.usage}
''');
    exit(0);
  }

  final configPath = args['config'] as String;
  final configFile = File(configPath);

  if (!await configFile.exists()) {
    stderr.writeln('❌ Config file not found at: $configPath');
    exit(1);
  }

    final raw = await configFile.readAsString();
    Map<String, dynamic> json;
  try {
    json = jsonDecode(raw) as Map<String, dynamic>;
  } on FormatException catch (e) {
    stderr.writeln('❌ Invalid JSON in $configPath: ${e.message}');
    exit(1);
  }

  // 3) Parse into your config class
  late GeneratorConfig config;
  try {
    config = GeneratorConfig.fromJson(json);
  } catch (e) {
    stderr.writeln('❌ Error parsing config: $e');
    exit(1);
  }
  config.typeMappings ??= {
    "ID": "String",
    "String": "String",
    "Float": "Double",
    "Int": "Integer",
    "Boolean": "Boolean",
    "Null": "null"
  };


  
  final grammar = GQGrammar(typeMap: config.typeMappings!, mode: CodeGenerationMode.server);
  var file = File(graphqlFile);
  var schema = file.readAsLinesSync().join("\n");
  var gqParser = grammar.buildFrom(grammar.fullGrammar().end());
  gqParser.parse(schema);

  // lets generate some code!
  generateClasses(grammar);
  
}

void generateClasses(GQGrammar grammar) {
  final serialzer = JavaSerializer(grammar);
  final springSeriaalizer = SpringServerSerializer(grammar);
grammar.getSerializableTypes().forEach((def) {
    var text = serialzer.serializeTypeDefinition(def);
    writeToFile(text, "${def.token}.java", "types", ["$packageName.enums", "$packageName.interfaces"]);
  });
  grammar.interfaces.forEach((k, def) {
    var text = serialzer.serializeInterface(def);
    writeToFile(text, "$k.java", "interfaces", ["$packageName.enums", "$packageName.types"]);
  });
  grammar.enums.forEach((k, def) {
    var text = serialzer.serializeEnumDefinition(def);
    writeToFile(text, "$k.java", "enums", []);
  });
  grammar.inputs.forEach((k, def) {
    var text = serialzer.serializeInputDefinition(def);
    writeToFile(text, "$k.java", "inputs", ["$packageName.enums"]);
  });

  grammar.services.forEach((k, def) {
    var text = springSeriaalizer.serializeService(def);
    writeToFile(
        text, "$k.java", "services", ["$packageName.enums", "$packageName.types", "$packageName.inputs"]);
  });

  grammar.services.forEach((k, def) {
    var text = springSeriaalizer.serializeController(def);
    writeToFile(text, "${k}Controller.java", "controllers",
        ["$packageName.enums", "$packageName.types", "$packageName.inputs", "$packageName.services"]);
  });

  grammar.repositories.forEach((k, def) {
    var text = springSeriaalizer.serializeRepository(def);
    writeToFile(text, "${k}.java", "repositories", ["$packageName.enums", "$packageName.types"]);
  });
}

void writeToFile(String data, String fileName, String subpackage, List<String> imports) {
  var file = File("$destinationDir/$subpackage/$fileName");
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  var importsText = imports.map((i) => "import $i.*;").join("\n");
  file.writeAsStringSync("""
package $packageName.$subpackage;

$importsText

$data
""");
  print("Done wrting to  $fileName");
}
