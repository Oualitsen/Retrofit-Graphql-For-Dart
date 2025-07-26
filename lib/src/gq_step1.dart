import 'package:retrofit_graphql/src/excpetions/parse_exception.dart';
import 'package:retrofit_graphql/src/gq_model_data.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_enum_definition.dart';
import 'package:retrofit_graphql/src/model/gq_fragment.dart';
import 'package:retrofit_graphql/src/model/gq_input_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_interface.dart';
import 'package:retrofit_graphql/src/model/gq_queries.dart';
import 'package:retrofit_graphql/src/model/gq_scalar_definition.dart';
import 'package:retrofit_graphql/src/model/gq_schema.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_union.dart';

class GqStep1 {
  final GqModelData data;

  GQSchema schema = GQSchema();

  bool schemaInitialized = false;

  GqStep1(this.data);

  void addEnumDefinition(GQEnumDefinition enumDefinition) {
    _checkEnumDefinition(enumDefinition);
    data.enums[enumDefinition.token] = enumDefinition;
  }

  void _checkEnumDefinition(GQEnumDefinition enumDefinition) {
    if (data.enums.containsKey(enumDefinition.token)) {
      throw ParseException(
          "Enum ${enumDefinition.token} has already been declared");
    }
  }

  void _checkDirectiveDefinition(String name) {
    if (data.directiveDefinitions.containsKey(name)) {
      throw ParseException("Directive $name has already been declared");
    }
  }

  void _checkSacalarDefinition(GQScalarDefinition scalar) {
    if (data.scalars.containsKey(scalar.token)) {
      throw ParseException("Scalar $scalar has already been declared");
    }
  }

  void addScalarDefinition(GQScalarDefinition scalar) {
    _checkSacalarDefinition(scalar);
    data.scalars[scalar.token] = scalar;
  }

  void addDirectiveDefinition(GQDirectiveDefinition directive) {
    _checkDirectiveDefinition(directive.name);
    data.directiveDefinitions[directive.name] = directive;
  }

  void defineSchema(GQSchema schema) {
    if (schemaInitialized) {
      throw ParseException("A schema has already been defined");
    }
    schemaInitialized = true;
    this.schema = schema;
  }

  void _checkInputDefinition(GQInputDefinition input) {
    if (data.inputs.containsKey(input.token)) {
      throw ParseException("Input ${input.token} has already been declared");
    }
  }

  void _checkUnitionDefinition(GQUnionDefinition union) {
    if (data.unions.containsKey(union.token)) {
      throw ParseException("Union ${union.token} has already been declared");
    }
  }

  void addInputDefinition(GQInputDefinition input) {
    _checkInputDefinition(input);
    data.inputs[input.token] = input;
  }

  void addTypeDefinition(GQTypeDefinition type) {
    _checkTypeDefinition(type);
    data.types[type.token] = type;
  }

  void addInterfaceDefinition(GQInterfaceDefinition interface) {
    _checkInterfaceDefinition(interface);
    data.interfaces[interface.token] = interface;
  }

  void addFragmentDefinition(GQFragmentDefinitionBase fragment) {
    _checkFragmentDefinition(fragment);
    data.fragments[fragment.token] = fragment;
  }

  void addUnionDefinition(GQUnionDefinition union) {
    _checkUnitionDefinition(union);
    data.unions[union.token] = union;
  }

  void addQueryDefinition(GQQueryDefinition definition) {
    _checkQueryDefinition(definition.token);
    data.queries[definition.token] = definition;
  }

  void _checkQueryDefinition(String token) {
    if (data.queries.containsKey(token)) {
      throw ParseException("Query $token has already been declared");
    }
  }

  void _checkInterfaceDefinition(GQInterfaceDefinition interface) {
    if (data.interfaces.containsKey(interface.token)) {
      throw ParseException(
          "Interface ${interface.token} has already been declared");
    }
  }

  void _checkTypeDefinition(GQTypeDefinition type) {
    if (data.types.containsKey(type.token)) {
      throw ParseException("Type ${type.token} has already been declared");
    }
  }

  void _checkFragmentDefinition(GQFragmentDefinitionBase fragment) {
    if (data.fragments.containsKey(fragment.token)) {
      throw ParseException(
          "Fragment ${fragment.token} has already been declared");
    }
  }

  void checkFragmentExistance() {
    // do nothing
  }

  void checkTypeExistance(String id) {
    // do nothing here
  }
}
