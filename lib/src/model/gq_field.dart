import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_argument.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_has_directives.dart';
import 'package:retrofit_graphql/src/model/gq_type.dart';

class GQField with GqHasDirectives {
  final String name;
  final GQType type;
  final Object? initialValue;
  final String? documentation;
  final List<GQArgumentDefinition> arguments;
  
  final List<GQDirectiveValue> directives;

  bool? _isArray;

  bool? _containsSkipOrIncludeDirective;

  String? _hashCache;

  GQField({
    required this.name,
    required this.type,
    required this.arguments,
    this.initialValue,
    this.documentation,
    required this.directives,
  });

  @override
  bool operator ==(Object other) {
    if (other is GQField && runtimeType == other.runtimeType) {
      return name == other.name && type == other.type;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode * type.hashCode;

  @override
  String toString() {
    return 'GraphqlField{name: $name, type: ${type.serialize()}, initialValue: $initialValue, documentation: $documentation, arguments: $arguments}';
  }

  String createHash() {
    var cache = _hashCache;
    if (cache == null) {
      _hashCache = cache = "hASH";//"${serializer.serializeType(type, hasInculeOrSkipDiretives)} $name";
    }
    return cache;
  }

  //check for inclue or skip directives
  bool get hasInculeOrSkipDiretives => _containsSkipOrIncludeDirective ??= directives
      .where((d) => [GQGrammar.includeDirective, GQGrammar.skipDirective].contains(d.token))
      .isNotEmpty;

  bool get serialzeAsArray {
    _isArray ??= directives.where((e) => e.token == GQGrammar.gqArray).isNotEmpty;
    return _isArray!;
  }

  @override
  List<GQDirectiveValue> getDirectives() {
    return [... directives];
  }
}
