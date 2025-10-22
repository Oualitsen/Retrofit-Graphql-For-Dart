import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_input_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_token.dart';
import 'package:retrofit_graphql/src/utils.dart';

class GQInputView extends GQToken {
  final GQInputDefinition input;

  GQInputView({required this.input}) : super(input.tokenInfo.ofNewName(widgetName(input.token))) {
    addImport('package:flutter/material.dart');
  }

  

  @override
  Set<GQToken> getImportDependecies(GQGrammar g) {
    var result = <GQToken>{};
    result.add(input);
    var fields = input.getSerializableFields(g.mode);
    // grab the enums
    fields
        .where((f) => g.isEnum(f.type.token))
        .forEach((f) => result.add(g.enums[f.type.token]!));
    // grab the widgets
    
    fields
        .where((f) => g.projectedTypes.containsKey(f.type.token))
        .forEach((f) => result.add(g.views[widgetName(f.type.token)]!));

    return result;
  }
}
