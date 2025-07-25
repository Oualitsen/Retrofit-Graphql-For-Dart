import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/gq_enum_definition.dart';
import 'package:retrofit_graphql/src/model/gq_input_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_interface.dart';
import 'package:retrofit_graphql/src/model/gq_queries.dart';
import 'package:retrofit_graphql/src/model/gq_service.dart';
import 'package:retrofit_graphql/src/model/gq_shcema_mapping.dart';
import 'package:retrofit_graphql/src/model/gq_type_definition.dart';
import 'package:retrofit_graphql/src/model/gq_union.dart';

class GqStep1 {

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
  

}