import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';

class FlutterTypeWidgetSerializer {
  final GQGrammar grammar;

  FlutterTypeWidgetSerializer(this.grammar);

  String serializeType(GQTypeDefinition type) {
    return '''
class ${type.token}Widget extends StatelessWidget {

  final ${type.token} value;

  @override
  Widget build(BuildContext context) {
    return Column(children:[
      ${type.fields.map((f) => serializeFieldAsListTile(f, 'value.${f.name}'))}
    ]);
  }

}

''';
  }

  String serializeFieldAsListTile(GQField field, String value) {
    return '''
return ListTile(
  title: Text(${field.name})
  subTitle: Text(${value})
);

''';
  }
}
