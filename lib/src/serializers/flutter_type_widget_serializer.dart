import 'package:retrofit_graphql/src/extensions.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_type.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';
import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';

class FlutterTypeWidgetSerializer {
  final GQGrammar grammar;
  final DartSerializer serializer;
  final bool useApplocalisation;

  FlutterTypeWidgetSerializer(
      this.grammar, this.serializer, this.useApplocalisation);

  String serializeType(GQTypeDefinition type) {
    var fields = type.getSerializableFields(grammar.mode);
    var buffer = StringBuffer();
    final widgetName = '${type.token}Widget';

    buffer.writeln('class ${widgetName} extends StatelessWidget {');
    buffer.writeln('final ${type.token} value;'.ident());
    // field orders
    for (var field in fields) {
      buffer.writeln('final int ${orderVar(field)};'.ident());
    }
    buffer.writeln();
    // field visibility
    for (var field in fields) {
      buffer.writeln('final bool ${visibleVar(field)};'.ident());
    }
    buffer.writeln();

    // field labels
    for (var field in fields) {
      buffer.writeln('final String? ${labelVar(field)};'.ident());
    }
    buffer.writeln();

    // replacement widgets
    for (var field in fields) {
      buffer.writeln('final Widget? ${widgetVar(field)};'.ident());
    }
    buffer.writeln();

    // label style
    buffer.writeln('final TextStyle? labelStyle;'.ident());
    buffer.writeln('final TextStyle? valueStyle;'.ident());

    // space between

    buffer.writeln('final double spaceBetween;'.ident());

    // flex

    buffer.writeln('final int labelFlex;'.ident());
    buffer.writeln('final int valueFlex;'.ident());

    // layout
    buffer.writeln('final bool verticalLayout;'.ident());
    // transformers

    for (var field in fields) {
      var fieldType = field.type.firstType;
      if (grammar.isNonProjectableType(fieldType.token)) {
        final serialType = serializer.serializeType(fieldType, false);
        buffer.writeln('final String Function(${serialType})? ${transVar(field)};'.ident());
      }
    }
    // the constructor

    buffer.writeln(serializeConstructor(widgetName, fields).ident());

    // utility functions
    buffer.writeln('''
Widget _wrapWidget(Widget label, Widget value) {
    switch (viewType) {
      case FieldViewType.listTile:
        return ListTile(title: (label), subtitle: (value));
      case FieldViewType.reversedListTile:
        return ListTile(title: (label), subtitle: (value));
      case FieldViewType.labelValueRow:
        return Row(
          children: [
            Expanded(flex: labelFlex, child: label),
            Expanded(flex: valueFlex, child: value),
          ],
        );
    }
  }
'''.ident());

    buffer.writeln('''
Widget _createLabelWidget(String name, BuildContext context) {
    String value = _getLabel(name, context);
    if (viewType == FieldViewType.labelValueRow) {
      return Text(value, style: labelStyle ?? TextStyle(fontWeight: FontWeight.bold));
    } else {
      return Text(value, style: labelStyle);
    }
  }
'''.ident());

    buffer.writeln(serializeGetLabel(type).ident());
    buffer.writeln(serializeGetInBetweenWidget().ident());


    // build method
    buffer.writeln(serializeBuildMethod(fields).ident());

    return buffer.toString();
  }

  String serializeConstructor(String widgetName, List<GQField> fields) {
    final buffer = StringBuffer();

    buffer.writeln('${widgetName}({');
    buffer.writeln('super.key,'.ident());
    buffer.writeln('required this.value,'.ident());
    // orders
    for (var i = 0, field = fields[i]; i < fields.length; i++) {
      buffer.writeln('this.${orderVar(field)} = ${i},'.ident());
    }

    // visibility
    for (var i = 0, field = fields[i]; i < fields.length; i++) {
      buffer.writeln('this.${visibleVar(field)} = true,'.ident());
    }

    // field labels
    for (var i = 0, field = fields[i]; i < fields.length; i++) {
      buffer.writeln('this.${labelVar(field)},'.ident());
    }

    // replacement widgets
    for (var i = 0, field = fields[i]; i < fields.length; i++) {
      buffer.writeln('this.${widgetVar(field)},'.ident());
    }

    // transformers

    for (var field in fields) {
      var fieldType = field.type.firstType;
      if (grammar.isNonProjectableType(fieldType.token)) {
        buffer.writeln('this.${transVar(field)},'.ident());
      }
    }

    // viewType
    buffer.writeln('this.viewType = FieldViewType.labelValueRow,'.ident());
    // flex
    buffer.writeln('this.labelFlex = 1,'.ident());
    buffer.writeln('this.valueFlex = 1,'.ident());
    // space between
    buffer.writeln('this.spaceBetween = 10.0,'.ident());
    // styles
    buffer.writeln('this.labelStyle,'.ident());
    buffer.writeln('this.valueStyle,'.ident());

    // end
    buffer.writeln('});');
    return buffer.toString();
  }

  String serializeBuildMethod(List<GQField> fields) {
    
    final buffer = StringBuffer();
    buffer.writeln("@override");
    buffer.writeln('Widget build(BuildContext context) {');
    buffer.writeln('final ${widgetsVar} = <MapEntry<Widget, int>>[]'.ident());
    for(var field in fields) {

      buffer.writeln(
        'if(${visibleVar(field)}) {'.ident()
      );
      buffer.writeln('if(${widgetVar(field)} != null) {'.ident(3));
      buffer.writeln('${widgetsVar}.add(MapEntry(${widgetVar(field)}, ${orderVar(field)}));'.ident(2));

      buffer.writeln('} else {'.ident(3));
      buffer.writeln('${widgetsVar}.add(MapEntry(Text(${transVar(field)} != null ? ${transVar(field)}!(value.${field.name} : value.${field.name})), ${orderVar(field)}));'.ident(2));
      buffer.write('}'.ident(3));
      buffer.writeln('}');
    }
    buffer.writeln("${widgetsVar}.sort((a, b) => (a.value - b.value));");
    buffer.writeln("final \$\$inbetweenWidget = _getInBetweenWidget();");
    buffer.writeln("final ${childrenVar} = ${widgetsVar}.expand((e) => e == ${widgetsVar}.last ? [e.key]: [e.key, if (\$\$inbetweenWidget != null) \$\$inbetweenWidget]).toList();");
    buffer.writeln("if (verticalLayout) {");
    buffer.writeln("return Column(children: ${childrenVar});");
    buffer.writeln("} else {");
    buffer.writeln("return Row(children: ${childrenVar});");
    buffer.writeln("}");


    
    return buffer.toString();
  }

  String createMapEntry(GQField field) {
    var buffer = StringBuffer();
    buffer.writeln("MapEntry(${widgetVar(field)} ??");
    buffer.writeln("_wrapWidget(_createLabelWidget('${field.name}', context),");
    buffer.writeln("Text(");
    buffer.writeln("${transVar(field)} != null ? ${transVar(field)}!(value.${field.name}) : value.${field.name}");
    buffer.writeln(")");
    buffer.write(orderVar(field));
    buffer.write(")");
    return buffer.toString();
  }

  String serializeGetInBetweenWidget() {
    final buffer = StringBuffer();
    buffer.writeln("Widget? _getInBetweenWidget() {");
    buffer.writeln("if(spaceBetween <= 0) {".ident());
    buffer.writeln("return null;".ident(2));
    buffer.writeln("}".ident());
    buffer.writeln("if(verticalLayout) {".ident());
    buffer.writeln("return SizedBox(height: spaceBetween);".ident(2));
    buffer.writeln("}".ident());
    buffer.writeln("return SizedBox(width: spaceBetween);".ident());
    buffer.writeln("}");
    return buffer.toString();
  }

  String visibleVar(GQField field) {
    return "${field.name}Visible";
  }

   String labelVar(GQField field) {
    return "${field.name}Label";
  }

  String widgetVar(GQField field) {
    return "${field.name}Widget";
  }

  String orderVar(GQField field) {
    return "${field.name}Order";
  }

  String transVar(GQField field) {
    return "${field.name}Transformer";
  }
  String get widgetsVar => "\$\$widgets";
  String get childrenVar => "\$\$children";

  String serializeGetLabel(GQTypeDefinition type) {
    var fields = type.getSerializableFields(grammar.mode);
    var buffer = StringBuffer();
    buffer
        .writeln('String _getLabel(String fieldName, BuildContext context) {');
    buffer.writeln("String result;".ident());
    if (useApplocalisation) {
      buffer.writeln('final lang = AppLocalizations.of(context)!;'.ident());
    }

    buffer.writeln('switch (fieldName) {'.ident());
    for (var field in fields) {
      buffer.writeln("case '${field.name}':".ident(2));
      buffer.write("result = ${labelVar(field)} ?? ".ident(3));
      if (useApplocalisation) {
        buffer
            .writeln("lang.${type.token.firstLow}${field.name.token.firstUp};");
      } else {
        buffer.writeln('fieldName;');
      }
      buffer.writeln('break;'.ident(3));
    }
    buffer.writeln('default:'.ident(2));
    buffer.writeln('result = fieldName;'.ident(2));
    buffer.writeln('}');
    buffer.writeln('return result;'.ident());
    return buffer.toString();
  }
}
