import 'package:retrofit_graphql/src/model/gq_directive.dart';

mixin GqHasDirectives {
  List<GQDirectiveValue> getDirectives() {
    return [..._directives];
  }

  final List<GQDirectiveValue> _directives = [];

  final Map<String, GQDirectiveValue?> _cache = {};

  void addDirective(GQDirectiveValue directiveValue) {
    _directives.add(directiveValue);
  }

  GQDirectiveValue? getDirectiveByName(String name) {
    var result = _cache[name];
    if (result == null && !_cache.containsKey(name)) {
      var directiveList = getDirectives().where((d) => d.token == name).toList();
      if (directiveList.isEmpty) {
        result = null;
      } else {
        result = directiveList.first;
      }
      _cache[name] = result;
    }
    return result;
  }
}
