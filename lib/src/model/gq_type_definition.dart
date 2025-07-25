import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_has_directives.dart';
import 'package:retrofit_graphql/src/model/gq_token.dart';
import 'package:retrofit_graphql/src/model/built_in_dirctive_definitions.dart';

class GQTypeDefinition extends GQTokenWithFields with GqDirectivesMixin {
  final Set<String> interfaceNames;
  final bool nameDeclared;
  final GQTypeDefinition? derivedFromType;

  final Set<String> originalTokens = <String>{};

  ///
  /// Used only when generating type for interfaces.
  /// This will be a super class of one or more base types.
  ///
  final Set<GQTypeDefinition> subTypes = {};

  GQTypeDefinition({
    required String name,
    required this.nameDeclared,
    required List<GQField> fields,
    required this.interfaceNames,
    required List<GQDirectiveValue> directives,
    required this.derivedFromType,
  }) : super(name, fields) {
    directives.forEach(addDirective);
    fields.sort((f1, f2) => f1.name.compareTo(f2.name));
  }

  ///
  ///check is the two definitions will produce the same object structure
  ///
  bool isSimilarTo(GQTypeDefinition other, GQGrammar g) {
    var dft = derivedFromType;
    var otherDft = other.derivedFromType;
    if (otherDft != null) {
      if ((dft?.token ?? token) != otherDft.token) {
        return false;
      }
    }
    return getHash(g) == other.getHash(g);
  }

  String getHash(GQGrammar g) {
    return getSerializableFields(g)
        .map((f) => "${f.name}:${f.type.serializeForceNullable(f.hasInculeOrSkipDiretives)}")
        .join(",");
  }

  Set<String> getIdentityFields(GQGrammar g) {
    var directive = getDirectiveByName(gqEqualsHashcode);
    if (directive != null) {
      var directiveFields = ((directive.getArguments().first.value as List)[1] as List)
          .map((e) => e as String)
          .map((e) => e.replaceAll('"', '').replaceAll("'", ""))
          .toSet();
      return directiveFields.where((e) => fieldNames.contains(e)).toSet();
    }
    return g.identityFields.where((e) => fieldNames.contains(e)).toSet();
  }

  @override
  String toString() {
    return 'GraphqlType{name: $token, fields: $fields, interfaceNames: $interfaceNames}';
  }

  List<GQField> getFields() {
    return [...fields];
  }

  String serializeContructorArgs(GQGrammar grammar) {
    if (fields.isEmpty) {
      return "";
    }
    String nonCommonFields =
        getFields().isEmpty ? "" : getFields().map((e) => grammar.toConstructorDeclaration(e)).join(", ");
    var combined = [nonCommonFields].where((element) => element.isNotEmpty).toSet();
    if (combined.isEmpty) {
      return "";
    } else if (combined.length == 1) {
      return "{${combined.first}}";
    }
    return "{${[nonCommonFields].join(", ")}}";
  }

  @override
  String serialize() {
    throw UnimplementedError();
  }

  GQTypeDefinition clone(String newName) {
    return GQTypeDefinition(
      name: newName,
      nameDeclared: nameDeclared,
      fields: fields.toList(),
      interfaceNames: interfaceNames,
      directives: [],
      derivedFromType: derivedFromType,
    );
  }
}
