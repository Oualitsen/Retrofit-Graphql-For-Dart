import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_token.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';

class GQTypeView extends GQToken {
  final GQTypeDefinition type;

  GQTypeView({required this.type}) : super(type.tokenInfo) {
    addImport('package:flutter/material.dart');
  }

  @override
  Set<GQToken> getImportDependecies(GQGrammar g) {
    var result = <GQToken>{};
    result.add(type);
    result.add(g.getTokenByKey('GQFieldViewType')!);
    // grab the enums
    type.fields
        .where((f) => g.isEnum(f.type.token))
        .forEach((f) => result.add(g.enums[f.type.token]!));
    return result;
  }
}
