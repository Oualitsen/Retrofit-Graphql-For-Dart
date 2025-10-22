import 'package:retrofit_graphql/src/code_gen_utils.dart';
import 'package:retrofit_graphql/src/extensions.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_enum_definition.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';
import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';
import 'package:retrofit_graphql/src/ui/flutter/gq_type_view.dart';

class FlutterInputWidgetSerializer {
  final GQGrammar grammar;
  final DartSerializer serializer;
  final bool useApplocalisation;
  final codeGenUtils = DartCodeGenUtils();

  FlutterInputWidgetSerializer(
      this.grammar, this.serializer, this.useApplocalisation);

  String _widgetName(String typeName) {
    return '${typeName}Widget';
  }


}
