import 'package:retrofit_graphql/src/code_gen_utils.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_field.dart';
import 'package:retrofit_graphql/src/model/gq_input_type_definition.dart';
import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';
import 'package:retrofit_graphql/src/ui/flutter/gq_input_view.dart';
import 'package:retrofit_graphql/src/utils.dart';

class FlutterInputWidgetSerializer {
  final GQGrammar grammar;
  final DartSerializer serializer;
  final bool useApplocalisation;
  final codeGenUtils = DartCodeGenUtils();

  FlutterInputWidgetSerializer(
      this.grammar, this.serializer, this.useApplocalisation);

  List<GQField> _getSimpleTypes(GQInputDefinition def) => def.fields
      .where((f) => grammar.isNonProjectableType(f.type.token))
      .toList();

  String generateInputWidget(GQInputView view, String prefix) {
    var buffer = StringBuffer();
    var imports = serializer.serializeImports(view, prefix);
    buffer.writeln(imports);
    buffer.writeln();
    buffer.writeln(_generateStatefulWidget(view));
    buffer.writeln();
    buffer.writeln(_generateStateClass(view));
    return buffer.toString();
  }

  String _generateStatefulWidget(GQInputView view) {
    final name = widgetName(view.token);
    final stateName = widgetStateName(view.token);
    return codeGenUtils.createClass(className: name, baseClassNames: [
      'StatefulWidget'
    ], statements: [
      'final ${view.input.token}? initial;',
      'final bool required;',
      'final double spaceBetween;',
      'final bool verticalLayout;',
      'final TextStyle? labelStyle;',
      // orders
      for (var i = 0; i < view.input.fields.length; i++)
        'final int ${orderVar(view.input.fields[i])};',
      // visbility
      for (var i = 0; i < view.input.fields.length; i++)
        'final bool ${visibleVar(view.input.fields[i])};',
      ..._getSimpleTypes(view.input).map((e) =>
          'final String Function(${serializer.serializeType(e.type.firstType, false)} value)? ${viewTransVar(e)};'),
      ..._getSimpleTypes(view.input).map((e) =>
          'final ${serializer.serializeType(e.type, false)} Function(String? input)? ${inputTransVar(e)};'),

      ..._getSimpleTypes(view.input).map((e) =>
          'final String? Function(String? text)? ${validatorVar(e)};'),

      codeGenUtils
          .createMethod(returnType: 'const', methodName: name, arguments: [
        'super.key,',
        'this.initial,',
        'this.required = false,',
        'this.spaceBetween = 10,',
        'this.verticalLayout = true,',
        'this.labelStyle,',
        for (var i = 0; i < view.input.fields.length; i++)
          'this.${orderVar(view.input.fields[i])} = ${i},',
        for (var i = 0; i < view.input.fields.length; i++)
          'this.${visibleVar(view.input.fields[i])} = true,',
        // transformers
        ..._getSimpleTypes(view.input)
            .map((field) => 'this.${viewTransVar(field)},'),
        ..._getSimpleTypes(view.input)
            .map((field) => 'this.${inputTransVar(field)},'),
        ..._getSimpleTypes(view.input)
            .map((field) => 'this.${validatorVar(field)},'),
      ]),
      '@override',
      'State<${name}> createState() => ${stateName}();'
    ]);
  }

  String _generateStateClass(GQInputView view) {
    final name = widgetName(view.token);
    final stateName = widgetStateName(view.token);
    return codeGenUtils.createClass(className: stateName, baseClassNames: [
      'State<${name}>'
    ], statements: [
      '',
      'final _formKey = GlobalKey<FormState>();',
      'bool _inited = false;',
      // controllers
      ..._getControllerDeclarations(view.input),
      _buildBuildMethod(view.input),
      '',
      codeGenUtils.createMethod(
          returnType: 'void',
          methodName: '_initWidget',
          statements: [
            codeGenUtils.ifStatement(
                condition: '_inited', ifBlockStatements: ['return;']),
            '_inited = true;',
            'var init = widget.initial;',
            codeGenUtils.ifStatement(
                condition: 'init != null',
                ifBlockStatements: _getInitializations(view.input)),
          ]),
      '',
      '@override',
      codeGenUtils.createMethod(
          returnType: 'void',
          methodName: 'dispose',
          statements: [
            ..._getControllerDisposals(view.input),
            'super.dispose();'
          ]),
      '',
      serializeGetInBetweenWidget(),
    ]);
  }

  String _buildBuildMethod(GQInputDefinition def) {
    var buffer = StringBuffer();
    buffer.writeln('@override');

    var methodStatements = <String>[
      '_initWidget();',
      'final ${widgetsVar} = <MapEntry<Widget, int>>[];',
      ...def.fields.map((field) =>
          '${widgetsVar}.add(MapEntry(${_createInputForField(field)}, widget.${orderVar(field)}));'),
      '${widgetsVar}.sort((a, b) => (a.value - b.value));',
      'final \$\$inbetweenWidget = _getInBetweenWidget();',
      "final ${childrenVar} = ${widgetsVar}.expand((e) => e == ${widgetsVar}.last ? [e.key]: [e.key, if (\$\$inbetweenWidget != null) \$\$inbetweenWidget]).toList();",
      'final Widget \$\$formChild;',
      codeGenUtils.ifStatement(
          condition: 'widget.verticalLayout',
          ifBlockStatements: [
            "\$\$formChild = Column(children: ${childrenVar});"
          ],
          elseBlockStatements: [
            "\$\$formChild = Row(children: ${childrenVar});"
          ]),
      'return Form(key: _formKey, child: \$\$formChild);'
    ];

    buffer.writeln(
      codeGenUtils.createMethod(
          returnType: 'Widget',
          methodName: 'build',
          namedArguments: false,
          arguments: ['BuildContext context'],
          statements: methodStatements),
    );

    return buffer.toString();
  }

  String _createInputForField(GQField field) {
    var validator = codeGenUtils
        .createMethod(namedArguments: false, methodName: '', arguments: [
      'String? text'
    ], statements: [
      codeGenUtils.ifStatement(
          condition: 'widget.${validatorVar(field)} != null',
          ifBlockStatements: [
            
            if (!field.type.nullable)...[
              'var result = widget.${validatorVar(field)}!.call(text);',
              codeGenUtils.ifStatement(
                  condition: 'result == null',
                  ifBlockStatements: ["return 'required field';"],
                  elseBlockStatements: ['return result;']),]
                  else 'return widget.${validatorVar(field)}!.call(text);',
          ]),
      'return null;'
    ]);
    return 'TextFormField(controller: ${_controllerVar(field.name.token)}, validator: ${validator})';
  }

  List<String> _getControllerDeclarations(GQInputDefinition def) {
    return def.fields
        .map((e) =>
            'final ${_controllerVar(e.name.token)} = TextEditingController();')
        .toList();
  }

  List<String> _getControllerDisposals(GQInputDefinition def) {
    return def.fields
        .map((e) => '${_controllerVar(e.name.token)}.dispose();')
        .toList();
  }

  List<String> _getInitializations(GQInputDefinition def) {
    return _getSimpleTypes(def).map(_getFieldInitialization).toList();
  }

  String _getFieldInitialization(GQField field) {
    return codeGenUtils.ifStatement(
        condition: "widget.${viewTransVar(field)} != null",
        ifBlockStatements: [
          '${_controllerVar(field.name.token)}.text = widget.${viewTransVar(field)}!.call(init.${field.name.token});'
        ],
        elseBlockStatements: [
          '${_controllerVar(field.name.token)}.text = init.${field.name.token}${field.type.nullable ? " ?? ''" : ''};'
        ]);
  }

  String _controllerVar(String val) => '_${val}Ctrl';

  String viewTransVar(GQField field) {
    return "${field.name}ViewTransformer";
  }

  String inputTransVar(GQField field) {
    return "${field.name}InputTransformer";
  }

  String validatorVar(GQField field) {
    return "${field.name}Validator";
  }

  String visibleVar(GQField field) {
    return "${field.name}Visible";
  }

  String labelVar(GQField field) {
    return "${field.name}Label";
  }

  String orderVar(GQField field) {
    return "${field.name}Order";
  }

  String serializeGetInBetweenWidget() {
    return codeGenUtils.method(
        returnType: "Widget?",
        methodName: "_getInBetweenWidget",
        statements: [
          codeGenUtils.ifStatement(
              condition: "widget.spaceBetween <= 0",
              ifBlockStatements: ["return null;"]),
          codeGenUtils.ifStatement(
              condition: "widget.verticalLayout",
              ifBlockStatements: [
                "return SizedBox(height: widget.spaceBetween);"
              ]),
          "return SizedBox(width: widget.spaceBetween);"
        ]);
  }

  String get widgetsVar => "\$\$widgets";
  String get childrenVar => "\$\$children";
}
