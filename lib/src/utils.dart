import 'dart:math';

import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/built_in_dirctive_definitions.dart';
import 'package:retrofit_graphql/src/model/gq_directives_mixin.dart';
import 'package:retrofit_graphql/src/serializers/language.dart';

String serializeListText(List<String>? list, {String join = ",", bool withParenthesis = true}) {
  if (list == null || list.isEmpty) {
    return '';
  }
  String result;
  if (withParenthesis) {
    result = "(${list.join(join).trim()})";
  } else {
    result = list.join(join);
  }
  return result.trim();
}

String? getFqcnFromDirective(GQDirectiveValue value) {
  var fqcn = value.getArgValueAsString(gqClass);
  if (fqcn != null && !fqcn.startsWith("@")) {
    fqcn = "@$fqcn";
  }
  return fqcn;
}

String formatUnformattedGraphQL(String unformattedGraphQL) {
  const indentSize = 2;
  var currentIndent = 0;
  var formattedGraphQL = '';

  final lines = unformattedGraphQL.split('\n');

  for (final line in lines) {
    final trimmedLine = line.trim();

    if (trimmedLine.isNotEmpty) {
      if (trimmedLine.startsWith('}')) {
        currentIndent -= indentSize;
      }

      formattedGraphQL += '${' ' * currentIndent}$trimmedLine\n';

      if (trimmedLine.endsWith('{')) {
        currentIndent += indentSize;
      }
    }
  }

  return formattedGraphQL.trim();
}

String? getNameValueFromDirectives(Iterable<GQDirectiveValue> directives) {
  var dirs = directives.where((element) => GQGrammar.directivesToSkip.contains(element.token));
  if (dirs.isEmpty) {
    return null;
  }
  var name =
      dirs.first.getArguments().firstWhere((arg) => arg.token == gqTypeNameDirectiveArgumentName).value as String;
  return name.replaceAll("\"", "");
}

String generateUuid([String separator = "-"]) {
  final random = Random();
  const hexDigits = '0123456789abcdef';

  String generateRandomString(int length) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final randomIndex = random.nextInt(hexDigits.length);
      buffer.write(hexDigits[randomIndex]);
    }
    return buffer.toString();
  }

  return [
    generateRandomString(8),
    generateRandomString(4),
    generateRandomString(4),
    generateRandomString(4),
    generateRandomString(12),
  ].join(separator);
}

// java
const _primitiveToBoxed = {
  'byte': 'Byte',
  'short': 'Short',
  'int': 'Integer',
  'long': 'Long',
  'float': 'Float',
  'double': 'Double',
  'char': 'Character',
  'boolean': 'Boolean',
};

String convertPrimitiveToBoxed(String type) {
  return _primitiveToBoxed[type] ?? type;
}

bool typeIsJavaPrimitive(String type) {
  return _primitiveToBoxed.containsKey(type);
}

String formatElapsedTime(DateTime startDate) {
  final now = DateTime.now();
  final difference = now.difference(startDate);

  final minutes = difference.inMinutes;
  final seconds = difference.inSeconds % 60;
  final milliseconds = difference.inMilliseconds % 1000;

  final parts = <String>[];

  if (minutes > 0) {
    parts.add('${minutes}m');
  }
  if (minutes > 0 || seconds > 0) {
    parts.add('${seconds}s');
  }
  parts.add('${milliseconds}ms');

  return parts.join(' ');
}

const _map = <CodeGenerationMode, String>{
  CodeGenerationMode.client: gqSkipOnClient,
  CodeGenerationMode.server: gqSkipOnServer,
};

bool shouldSkipSerialization({required List<GQDirectiveValue> directives, required CodeGenerationMode mode}) {
  String token = _map[mode]!;
  var skipOnList = directives.where((d) => d.token == token).toList();
  return skipOnList.isNotEmpty;
}

List<T> filterSerialization<T extends GQDirectivesMixin>(Iterable<T> list, CodeGenerationMode mode) {
  return list.where((element) => !shouldSkipSerialization(directives: element.getDirectives(), mode: mode)).toList();
}

bool shouldSkip(GQDirectivesMixin mixin, CodeGenerationMode mode) {
  return shouldSkipSerialization(directives: mixin.getDirectives(), mode: mode);
}


String widgetName(String typeName) => "${typeName}Widget";
String widgetStateName(String typeName) => "${typeName}WidgetState";