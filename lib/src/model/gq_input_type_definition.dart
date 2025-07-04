import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_has_directives.dart';
import 'package:retrofit_graphql/src/model/gq_token.dart';

class GQInputDefinition extends GQTokenWithFields with GqHasDirectives {
  final List<GQDirectiveValue> directives;
  GQInputDefinition({required this.directives, required String name, required List<GQField> fields})
      : super(name, fields);

  @override
  String toString() {
    return 'InputType{fields: $fields, name: $token}';
  }



  @override
  String serialize() {
    return """
      input $token {
      
      }
    """;
  }

  @override
  List<GQDirectiveValue> getDirectives() {
    return [...directives];
  }
}
