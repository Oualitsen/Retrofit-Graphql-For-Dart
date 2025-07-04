import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_argument.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_queries.dart';
import 'package:retrofit_graphql/src/model/gq_service.dart';
import 'package:retrofit_graphql/src/model/gq_shcema_mapping.dart';
import 'package:retrofit_graphql/src/model/gq_type.dart';
import 'package:retrofit_graphql/src/serializers/java_serializer.dart';
import 'package:retrofit_graphql/src/extensions.dart';
import 'package:retrofit_graphql/src/serializers/language.dart';

class SpringServerSerializer {
  final GQGrammar grammar;
  final JavaSerializer serializer;
  SpringServerSerializer(this.grammar)
      : assert(grammar.mode == CodeGenerationMode.server,
            "Gramar must be in code generation mode = `CodeGenerationMode.server`"),
        serializer = JavaSerializer(grammar);

  List<String> serializeServices() {
    return grammar.services.values.map((service) {
      return serializeService(service);
    }).toList();
  }

  String serializeController(GQService service) {
    // get schema mappings by service name
    final controllerName = "${service.name}Controller";
    final sericeInstanceName = service.name.firstLow;
    var mappings = grammar.schemaMappings.values.where((sm) => sm.serviceName == service.name).toList();

    return """
@org.springframework.stereotype.Controller
public class $controllerName {
${'private final ${service.name} $sericeInstanceName;'.ident()}
${serializer.generateContructor(controllerName, [
              GQField(
                  name: sericeInstanceName, type: GQType(service.name, false), arguments: [], directives: [])
            ], "public").ident()}

${service.getMethodNames().map((n) {
              var method = service.getMethod(n)!;
              var type = service.getMethodType(n)!;
              return serializehandlerMethod(type, method, sericeInstanceName);
            }).toList().join("\n").ident()}

${mappings.isNotEmpty ? "// schema mappings and batch mapping".ident() : ""}
${mappings.map((m) {
              return serializeMappingMethod(m, sericeInstanceName);
            }).toList().join("\n").ident()}
}
""";
  }

  String serializehandlerMethod(GQQueryType type, GQField method, String sericeInstanceName) {
    String statement =
        "return $sericeInstanceName.${method.name}(${method.arguments.map((arg) => arg.token).join(", ")});";

    return """
${getAnnotationByShcemaType(type)}
${serializer.serializeTypeReactive(gqType: createListTypeOnSubscription(method.type, type), reactive: type == GQQueryType.subscription)} ${method.name}(${serializeArgs(method.arguments, "@org.springframework.graphql.data.method.annotation.Argument")}) {
${statement.ident()}
}"""
        .trim();
  }

  GQType createListTypeOnSubscription(GQType type, GQQueryType queryType) {
    if (queryType == GQQueryType.subscription) {
      return GQListType(type, false);
    }
    return type;
  }

  String serializeService(GQService service) {
    // get schema mappings by service name
    var mappings =
        grammar.schemaMappings.values.where((sm) => !sm.forbid && sm.serviceName == service.name).toList();

    return """
public interface ${service.name} {
${service.getMethodNames().map((n) {
              var method = service.getMethod(n)!;
              var type = service.getMethodType(n)!;
              return "${serializer.serializeTypeReactive(gqType: createListTypeOnSubscription(method.type, type), reactive: type == GQQueryType.subscription)} ${method.name}(${serializeArgs(method.arguments)});";
            }).toList().join("\n").ident()}

${mappings.isNotEmpty ? "// schema mappings and batch mapping".ident() : ""}
${mappings.map((m) {
              return "${serializeMappingImplMethodHeader(m, true, true)};";
            }).toList().join("\n").ident()}

}
""";
  }

  String serializeArgs(List<GQArgumentDefinition> args, [String? prefix]) {
    return """
${args.map((a) => serializeArg(a)).map((e) {
      if (prefix != null) {
        return "$prefix $e";
      }
      return e;
    }).join(", ")}
"""
        .trim();
  }

  String serializeArg(GQArgumentDefinition arg) {
    return """
final ${serializer.serializeType(arg.type, false)} ${arg.token}
"""
        .trim();
  }

  String serializeMappingMethod(GQSchemaMapping mapping, String serviceInstanceName) {
    if (mapping.forbid) {
      final statement = """
throw new graphql.GraphQLException("Access denied to field '${mapping.type.token}.${mapping.field.name}'");
"""
          .trim();
      return """
${serializeMappingImplMethodHeader(mapping)} {
${statement.ident()}
}
  """;
    }
    final statement = """
return $serviceInstanceName.${mapping.key}(${mapping.field.name});
"""
        .trim();
    return """
${serializeMappingImplMethodHeader(mapping)} {
${statement.ident()}
}""";
  }

  String _getAnnotation(GQSchemaMapping mapping) {
    if (mapping.batch) {
      return """
@org.springframework.graphql.data.method.annotation.BatchMapping(type="${mapping.type.token}", field="${mapping.field.name}")
      """
          .trim();
    } else {
      return """
@org.springframework.graphql.data.method.annotation.SchemaMapping(type="${mapping.type.token}", field="${mapping.field.name}")
"""
          .trim();
    }
  }

  String _getReturnType(GQSchemaMapping mapping) {
    if (mapping.batch) {
      return """
java.util.Map<${mapping.type.token}, ${serializer.serializeType(mapping.field.type, false)}>
      """
          .trim();
    } else {
      return serializer.serializeTypeReactive(gqType: mapping.field.type, reactive: false);
    }
  }

  String _getArg(GQSchemaMapping mapping) {
    if (mapping.batch) {
      return "java.util.List<${mapping.type.token}> ${mapping.type.token.firstLow}List";
    } else {
      return "${mapping.type.token} ${mapping.type.token.firstLow}";
    }
  }

  String serializeMappingImplMethodHeader(GQSchemaMapping mapping,
      [bool skipAnnotation = false, bool skipQualifier = false]) {
    var result = "${_getReturnType(mapping)} ${mapping.key}(${_getArg(mapping)})";
    if (!skipQualifier) {
      result = "public $result";
    }
    if (skipAnnotation) {
      return result;
    }
    return """
${_getAnnotation(mapping)}
$result
"""
        .trim();
  }

  String getAnnotationByShcemaType(GQQueryType queryType) {
    String result;
    switch (queryType) {
      case GQQueryType.query:
        result = "QueryMapping";
        break;
      case GQQueryType.mutation:
        result = "MutationMapping";
        break;
      case GQQueryType.subscription:
        result = "SubscriptionMapping";
        break;
    }
    return "@org.springframework.graphql.data.method.annotation.$result";
  }
}
