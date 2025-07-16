import 'package:retrofit_graphql/src/excpetions/parse_exception.dart';
import 'package:retrofit_graphql/src/model/gq_directive.dart';
import 'package:retrofit_graphql/src/model/built_in_dirctive_definitions.dart';
import 'package:retrofit_graphql/src/serializers/language.dart';

mixin GqHasDirectives {
  List<GQDirectiveValue> getDirectives() {
    return _directives.values.toList();
  }

  final Map<String, GQDirectiveValue> _directives = {};

  List<GQDirectiveValue> getAnnotations({CodeGenerationMode? mode}) {
    return getDirectives()
        .where((d) => d.getArgValue(gqAnnotation) == true)
        .where((d) {
      switch (mode) {
        case CodeGenerationMode.client:
          return d.getArgValue(gqOnClient) == true;
        case CodeGenerationMode.server:
          return d.getArgValue(gqOnServer) == true;
        case null:
          return true;
      }
    }).toList();
  }

  void addDirective(GQDirectiveValue directiveValue) {
    if (_directives.containsKey(directiveValue.token)) {
      throw ParseException(
          "Directive '${directiveValue.token}' already exists");
    }
    _directives[directiveValue.token] = directiveValue;
  }

  void addDirectiveIfAbsent(GQDirectiveValue directiveValue) {
    _directives.putIfAbsent(directiveValue.token, () => directiveValue);
  }

  List<GQDirectiveValue> findQueryDirectives() {
    return getDirectives().where((dir) {
      var isQuery = dir.getArgValue(gqQueryArg);
      return isQuery != null && isQuery is bool && isQuery;
    }).toList();
  }

  GQDirectiveValue? getDirectiveByName(String name) {
    return _directives[name];
  }
}
