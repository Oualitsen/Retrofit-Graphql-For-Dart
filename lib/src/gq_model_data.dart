import 'package:retrofit_graphql/src/model/built_in_dirctive_definitions.dart';
import 'package:retrofit_graphql/src/model/gq_argument.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_enum_definition.dart';
import 'package:retrofit_graphql/src/model/gq_fragment.dart';
import 'package:retrofit_graphql/src/model/gq_input_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_interface.dart';
import 'package:retrofit_graphql/src/model/gq_queries.dart';
import 'package:retrofit_graphql/src/model/gq_scalar_definition.dart';
import 'package:retrofit_graphql/src/model/gq_schema.dart';
import 'package:retrofit_graphql/src/model/gq_service.dart';
import 'package:retrofit_graphql/src/model/gq_shcema_mapping.dart';
import 'package:retrofit_graphql/src/model/gq_type.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_union.dart';

class GqModelData {



  GQSchema schema = GQSchema();
  
  bool schemaInitialized = false;


  final Map<String, GQDirectiveDefinition> directives = {
    includeDirective: GQDirectiveDefinition(
      includeDirective,
      [GQArgumentDefinition("if", GQType("Boolean", false), [])],
      {GQDirectiveScope.FIELD},
    ),
    skipDirective: GQDirectiveDefinition(
      skipDirective,
      [GQArgumentDefinition("if", GQType("Boolean", false), [])],
      {GQDirectiveScope.FIELD},
    ),
    gqTypeNameDirective: GQDirectiveDefinition(
      gqTypeNameDirective,
      [GQArgumentDefinition(gqTypeNameDirectiveArgumentName, GQType("String", false, isScalar: false), [])],
      {
        GQDirectiveScope.INPUT_OBJECT,
        GQDirectiveScope.FRAGMENT_DEFINITION,
        GQDirectiveScope.QUERY,
        GQDirectiveScope.MUTATION,
        GQDirectiveScope.SUBSCRIPTION,
      },
    ),
    gqEqualsHashcode: GQDirectiveDefinition(
      gqEqualsHashcode,
      [GQArgumentDefinition(gqEqualsHashcodeArgumentName, GQType("[String]", false), [])],
      {GQDirectiveScope.OBJECT},
    ),
  };

  final Map<String, GQScalarDefinition> scalars = {
    "ID": GQScalarDefinition(token: "ID", directives: []),
    "Boolean": GQScalarDefinition(token: "Boolean", directives: []),
    "Int": GQScalarDefinition(token: "Int", directives: []),
    "Float": GQScalarDefinition(token: "Float", directives: []),
    "String": GQScalarDefinition(token: "String", directives: []),
    "null": GQScalarDefinition(token: "null", directives: [])
  };

  final Map<String, GQUnionDefinition> unions = {};
  final Map<String, GQInputDefinition> inputs = {};
  final Map<String, GQTypeDefinition> types = {};
  final Map<String, GQInterfaceDefinition> interfaces = {};
  final Map<String, GQInterfaceDefinition> repositories = {};
  final Map<String, GQQueryDefinition> queries = {};
  final Map<String, GQEnumDefinition> enums = {};
  final Map<String, GQTypeDefinition> projectedTypes = {};
  final Map<String, GQDirectiveDefinition> directiveDefinitions = {};
  final Map<String, GQSchemaMapping> schemaMappings = {};
  final Map<String, GQService> services = {};

  final Map<String, GQFragmentDefinitionBase> fragments = {};
  final Map<String, GQTypedFragment> typedFragments = {};

}