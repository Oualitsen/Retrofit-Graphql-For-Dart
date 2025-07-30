import 'package:retrofit_graphql/src/extensions.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_argument.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_enum_definition.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_fragment.dart';
import 'package:retrofit_graphql/src/model/gq_input_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_interface.dart';
import 'package:retrofit_graphql/src/model/gq_queries.dart';
import 'package:retrofit_graphql/src/model/gq_scalar_definition.dart';
import 'package:retrofit_graphql/src/model/gq_schema.dart';
import 'package:retrofit_graphql/src/model/gq_type.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_union.dart';
import 'package:retrofit_graphql/src/utils.dart';

class GraphqSerializer {
  final GQGrammar grammar;

  GraphqSerializer(this.grammar);

  String generateSchema() {
    final buffer = StringBuffer();
    var scalars = grammar.scalars.values.where((s) => !grammar.builtInScalars.contains(s.token))
    
    .map(serializeScalarDefinition)
    .join("\n");
    buffer.writeln(scalars);

    return buffer.toString();
  }

  String serializeScalarDefinition(GQScalarDefinition def) {
    return '''
scalar ${def.token} ${serializeDirectiveValueList(def.getDirectives())}
'''.trim();
  }

  String serializeDirectiveValueList(List<GQDirectiveValue> values) {
    return values.map(serializeDirectiveValue).join(" ");
  }

  String serializeDirectiveValue(GQDirectiveValue value) {
    final token = value.token;
    if (GQGrammar.directivesToSkip.contains(token)) {
      return "";
    }
    var arguments = value.getArguments();
    var args = arguments.isEmpty
        ? ""
        : "(${arguments.map((e) => serializeArgumentValue(e)).join(",")})";
    return "${token}$args";
  }

  String serializeDirectiveDefinition(GQDirectiveDefinition def) {
    return '''
directive ${def.name} ${serializeDirectiveArgs(def.arguments)} on ${def.scopes.map((e) => e.name).join(" | ")}
''';
  }

  String serializeDirectiveArgs(List<GQArgumentDefinition> arguments) {
    if (arguments.isEmpty) {
      return "";
    }
    var result = arguments.map(serializeArgumentDefinition).join(", ");
    return "($result)";
  }

  String serializeArgumentDefinition(GQArgumentDefinition def) {
    var r = "${def.token.dolarEscape()}:${serializeType(def.type)}";
    if (def.initialValue != null) {
      r += "=${def.initialValue}";
    }
    return r;
  }

  String serialzeSchemaDefinition(GQSchema schema) {
    return '''
  schema {
    query: ${schema.query}
    mutation: ${schema.mutation}
    subscription: ${schema.subscription}
  }
''';
  }

  String serializeInputDefinition(GQInputDefinition def) {
    return '''
input ${def.token} ${serializeDirectiveValueList(def.getDirectives())} {
  ${def.getSerializableFields(grammar).map(serializeField).join("\n")}
}
''';
  }

  String serializeTypeDefinition(GQTypeDefinition def) {
    return '''
type ${def.token} ${serializeDirectiveValueList(def.getDirectives())} {
  ${def.getSerializableFields(grammar).map(serializeField).join("\n")}
}
''';
  }

  String serializeInterfaceDefinition(GQInterfaceDefinition def) {
    return '''
interface ${def.token} ${serializeDirectiveValueList(def.getDirectives())} {
  ${def.getSerializableFields(grammar).map(serializeField).join("\n")}
}
''';
  }

  String serializeEnumDefinition(GQEnumDefinition def) {
    return '''
enum ${def.token} ${serializeDirectiveValueList(def.getDirectives())} {
  ${def.values.map(serializeEnumValue).join("\n")}
}
''';
  }

  String serializeEnumValue(GQEnumValue enumValue) {
    return '''
${enumValue.value} ${serializeDirectiveValueList(enumValue.getDirectives())}
'''
        .trim();
  }

  String serializeField(GQField field) {
    return '''
${field.name}: ${serializeType(field.type)}${serilaizeArgs(field.arguments)} ${serializeDirectiveValueList(field.getDirectives())}
''';
  }

  String serializeType(GQType gqType, {bool forceNullable = false}) {
    String nullableText =
        forceNullable ? '' : _getNullableText(gqType.nullable);
    if (gqType is GQListType) {
      return "[${serializeType(gqType.inlineType)}]${nullableText}";
    }
    return "${gqType.token}${nullableText}";
  }

  String _getNullableText(bool nullable) => nullable ? "" : "!";

  String serilaizeArgs(List<GQArgumentDefinition> arguments) {
    if (arguments.isEmpty) {
      return "";
    }
    var result = arguments.map(serializeArgumentDefinition).join(", ");
    return "($result)";
  }

  String serializeArgumentValue(GQArgumentValue value) {
    return "${value.token.dolarEscape()}:${"${value.value}".replaceFirst("\$", "\\\$")}";
  }

  String serializeInlineFragment(GQInlineFragmentDefinition def) {
    return """... on ${def.onTypeName} ${serializeDirectiveValueList(def.getDirectives())} ${serializeBlock(def.block)} """;
  }

  String serializeBlock(GQFragmentBlockDefinition def) {
    return """{${serializeListText(def.projections.values.map(serializeProjection).toList(), join: " ", withParenthesis: false)}}""";
  }

  String serializeFragmentDefinition(GQFragmentDefinition def) {
    return """fragment ${def.fragmentName} on ${def.onTypeName}${serializeDirectiveValueList(def.getDirectives())}${serializeBlock(def.block)}""";
  }

  String serializeFragmentDefinitionBase(GQFragmentDefinitionBase def) {
    if(def is GQFragmentDefinition) {
      return serializeFragmentDefinition(def);
    }else if(def is GQInlineFragmentDefinition) {
      return serializeInlineFragment(def);
    }
    throw "serialization of ${def.token} is not supported yet";
  }

  String serializeProjection(GQProjection proj) {
    if (proj is GQInlineFragmentsProjection) {
      return serializeListText(proj.inlineFragments.map(serializeInlineFragment).toList(),
          join: " ", withParenthesis: false);
    }
    final buffer = StringBuffer();
    if (proj.isFragmentReference) {
      buffer.write("...");
    }
    if (proj.alias != null) {
      buffer.write(proj.alias);
      buffer.write(":");
      
    } else {
      buffer.write(proj.targetToken);
    }
    if(proj.getDirectives().isNotEmpty){
    buffer.write(serializeDirectiveValueList(proj.getDirectives()));
    }

    if (proj.block != null) {
      buffer.write(serializeBlock(proj.block!));
    }
    return buffer.toString();

  }

  String serializeUnionDefinition(GQUnionDefinition def) {
    return "union ${def.token} = ${serializeListText(def.typeNames, withParenthesis: false, join: "|")}";
  }

  String serializeQueryDefinition(GQQueryDefinition def) {
    return """${def.type.name} ${def.token}${serializeListText(def.arguments.map(serializeArgumentDefinition).toList(), join: ",")}${serializeDirectiveValueList(def.getDirectives())}{${serializeListText(def.elements.map(serializeQueryElement).toList(), join: " ", withParenthesis: false)}}""";
  }

  String serializeQueryElement(GQQueryElement def) {
    return """${def.escapedToken}${serializeListText(def.arguments.map(serializeArgumentValue).toList(), join: ",")}${serializeDirectiveValueList(def.getDirectives())}${def.block != null ? serializeBlock(def.block!) : ''}""";
  }
}
