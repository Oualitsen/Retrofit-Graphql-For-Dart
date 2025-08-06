import 'dart:io';

import 'package:retrofit_graphql/src/model/built_in_dirctive_definitions.dart';
import 'package:retrofit_graphql/src/serializers/dart_serializer.dart';
import 'package:retrofit_graphql/src/serializers/java_serializer.dart';
import 'package:test/test.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  test("Java enum to json", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  enum Gender {male, female}
''');
    expect(parsed is Success, true);
    var gender = g.enums["Gender"]!;
    var serializer = JavaSerializer(g);
    var genderSerial = serializer.serializeEnumDefinition(gender);

    print(genderSerial);

    expect(
        genderSerial.split("\n").map((e) => e.trim()),
        containsAllInOrder([
          "public String toJson() {",
          "return name();",
          "}",
        ]));
  });

  test("Java enum from json", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  enum Gender {male, female}
''');
    expect(parsed is Success, true);
    var gender = g.enums["Gender"]!;
    var serializer = JavaSerializer(g);
    var genderSerial = serializer.serializeEnumDefinition(gender);
    expect(
        genderSerial.split("\n").map((e) => e.trim()),
        containsAllInOrder([
          "public static Gender fromJson(String value) {",
          "return java.util.Optional.ofNullable(value).map(Gender::valueOf).orElse(null);",
          "}",
        ]));
  });

  test("Java input tojson", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  scalar Long
  enum Gender {male, female}
  input CityInput {
    name: String!
  }
  input UserInput {
    id: ID
    name: String!
    middleName: String
    dateOfBirth: Long
    gender: Gender
    gender2: Gender!
    names: [String!]!
    deepGender: [[Gender]]!
    genders1: [Gender!]!
    genders2: [Gender]!
    genders3: [Gender!]
    city: CityInput
    city2: CityInput!
  }
''');
    expect(parsed is Success, true);
    var userInput = g.inputs["UserInput"]!;
    var serializer = JavaSerializer(g);
    var inputSerial = serializer.doSerializeInputDefinition(userInput);

    print(inputSerial);

    var file = File("test/java/json/test.java");
    file.writeAsStringSync('''
$inputSerial
${serializer.doSerializeInputDefinition(g.inputs['CityInput']!)}
${serializer.serializeEnumDefinition(g.enums['Gender']!)}
''');

    expect(
      inputSerial.split('\n').map((e) => e.trim()),
      containsAllInOrder([
        'public java.util.Map<String, Object> toJson() {',
        'java.util.Map<String, Object> map = new java.util.HashMap<>();',
        'map.put("id", id);',
        'map.put("name", name);',
        'map.put("middleName", middleName);',
        'map.put("dateOfBirth", dateOfBirth);',
        'map.put("gender", java.util.Optional.ofNullable(gender).map((e) -> e.toJson()).orElse(null));',
        'map.put("gender2", gender2.toJson());',
        'map.put("names", names.stream().map(e0 -> e0).collect(java.util.stream.Collectors.toList()));',
        'map.put("deepGender", deepGender.stream().map(e0 -> java.util.Optional.ofNullable(e0).map((e) -> e.stream().map(e1 -> java.util.Optional.ofNullable(e1).map((e) -> e.toJson()).orElse(null)).collect(java.util.stream.Collectors.toList())).orElse(null)).collect(java.util.stream.Collectors.toList()));',
        'map.put("genders1", genders1.stream().map(e0 -> e0.toJson()).collect(java.util.stream.Collectors.toList()));',
        'map.put("genders2", genders2.stream().map(e0 -> java.util.Optional.ofNullable(e0).map((e) -> e.toJson()).orElse(null)).collect(java.util.stream.Collectors.toList()));',
        'map.put("genders3", java.util.Optional.ofNullable(genders3).map((e) -> e.stream().map(e0 -> e0.toJson()).collect(java.util.stream.Collectors.toList())).orElse(null));',
        'map.put("city", java.util.Optional.ofNullable(city).map((e) -> e.toJson()).orElse(null));',
        'map.put("city2", city2.toJson());',
        'return map;',
        '}'
      ]),
    );
  });

  test("Java input tojson list as array", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  enum Gender {male, female}
  input UserInput {
    names: [String!]! ${gqArray}
    genderList: [Gender] ${gqArray}
    genderList2: [[Gender!]] ${gqArray}
  }
''');
    expect(parsed is Success, true);
    var userInput = g.inputs["UserInput"]!;
    var serializer = JavaSerializer(g);
    var inputSerial = serializer.doSerializeInputDefinition(userInput);

    expect(
      inputSerial.split('\n').map((e) => e.trim()),
      containsAllInOrder([
        'public java.util.Map<String, Object> toJson() {',
        'java.util.Map<String, Object> map = new java.util.HashMap<>();',
        'map.put("names", names == null ? null : java.util.stream.Stream.of(names).map(e0 -> e0).toArray());',
        'map.put("genderList", genderList == null ? null : java.util.stream.Stream.of(genderList).map(e0 -> java.util.Optional.ofNullable(e0).map((e) -> e.toJson()).orElse(null)).toArray());',
        'map.put("genderList2", genderList2 == null ? null : java.util.stream.Stream.of(genderList2).map(e0 -> e0 == null ? null : java.util.stream.Stream.of(e0).map(e1 -> e1.toJson()).toArray()).toArray());',
        'return map;',
        '}'
      ]),
    );
  });

  test("Java input tojson list of lists", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  scalar Long
  enum Gender {male, female}
  
  input UserInput {
    genders: [[Gender]]
  }
''');
    expect(parsed is Success, true);
    var userInput = g.inputs["UserInput"]!;
    var serializer = JavaSerializer(g);
    var inputSerial = serializer.doSerializeInputDefinition(userInput);

    expect(
      inputSerial.split("\n").map((e) => e.trim()),
      containsAllInOrder([
        'public java.util.Map<String, Object> toJson() {',
        'java.util.Map<String, Object> map = new java.util.HashMap<>();',
        'map.put("genders", java.util.Optional.ofNullable(genders).map((e) -> e.stream().map(e0 -> java.util.Optional.ofNullable(e0).map((e) -> e.stream().map(e1 -> java.util.Optional.ofNullable(e1).map((e) -> e.toJson()).orElse(null)).collect(java.util.stream.Collectors.toList())).orElse(null)).collect(java.util.stream.Collectors.toList())).orElse(null));',
        'return map;',
        '}'
      ]),
    );
  });

  test("Java type tojson", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  scalar Long
  enum Gender {male, female}
  type City {
    name: String!
  }
  type User {
    id: ID
    name: String!
    middleName: String
    dateOfBirth: Long
    gender: Gender
    gender2: Gender!
    genders1: [Gender]
    genders2: [Gender!]!
    genders3: [Gender]!
    city: City
    cities: [City]
  }
''');
    expect(parsed is Success, true);
    var useer = g.types["User"]!;
    var serializer = JavaSerializer(g);
    var userSerial = serializer.doSerializeTypeDefinition(useer);


    // same as input, so we only check for the existance of toJson method
    expect(
      userSerial.split("\n").map((e) => e.trim()),
      containsAllInOrder([
       'public java.util.Map<String, Object> toJson() {',
        'java.util.Map<String, Object> map = new java.util.HashMap<>();',
        "}"
      ]),
    );
  });

  test("Java input fromJson", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  scalar Long
  enum Gender {male, female}
  input CityInput {
    name: String!
  }
  input UserInput {
    id: ID
    name: String!
    middleName: String
    dateOfBirth: Long
    price: Float
    gender: Gender
  #  gender2: Gender!
  #  genders1: [Gender]
  #  genders2: [Gender!]!
  #  genders3: [Gender]!
  #  city: CityInput
  #  cities: [CityInput]
  #  doubleCities: [[CityInput]]
  }
''');

    expect(parsed is Success, true);
    var userInput = g.inputs["UserInput"]!;
    var serializer = JavaSerializer(g);
    var inputSerial = serializer.doSerializeInputDefinition(userInput);
    print(inputSerial);
     var fileName = "test/java/json/test.java";
    File(fileName).writeAsStringSync('''
${inputSerial}
${serializer.serializeEnumDefinition(g.enums["Gender"]!)}
${serializer.serializeInputDefinition(g.inputs["CityInput"]!)}
''');
return;
    expect(
      inputSerial.split("\n").map((e) => e.trim()),
      containsAllInOrder([
        "static UserInput fromJson(Map<String, dynamic> json) {",
        "return UserInput(",
        "id: json['id'] as String?,",
        "name: json['name'] as String,",
        "middleName: json['middleName'] as String?,",
        "dateOfBirth: json['dateOfBirth'] as int?,",
        "price: (json['price'] as num?)?.toDouble(),",
        "gender: json['gender'] == null ? null : Gender.fromJson(json['gender'] as String),",
        "gender2: Gender.fromJson(json['gender2'] as String),",
        "genders1: (json['genders1'] as List<dynamic>?)?.map((e0) => e0 == null ? null : Gender.fromJson(e0 as String)).toList(),",
        "genders2: (json['genders2'] as List<dynamic>).map((e0) => Gender.fromJson(e0 as String)).toList(),",
        "genders3: (json['genders3'] as List<dynamic>).map((e0) => e0 == null ? null : Gender.fromJson(e0 as String)).toList(),",
        "city: json['city'] == null ? null : CityInput.fromJson(json['city'] as Map<String, dynamic>),",
        "cities: (json['cities'] as List<dynamic>?)?.map((e0) => e0 == null ? null : CityInput.fromJson(e0 as Map<String, dynamic>)).toList(),",
        "doubleCities: (json['doubleCities'] as List<dynamic>?)?.map((e0) => (e0 as List<dynamic>?)?.map((e1) => e1 == null ? null : CityInput.fromJson(e1 as Map<String, dynamic>)).toList()).toList()",
        ");",
        "}"
      ]),
    );
  });

  test("Java type fromJson", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  scalar Long
  enum Gender {male, female}
  type City {
    name: String!
  }
  type User {
    id: ID
    name: String!
    middleName: String
    dateOfBirth: Long
  #  price: Float
  #  gender: Gender
  #  gender2: Gender!
  #  genders1: [Gender]
  #  genders2: [Gender!]!
  #  genders3: [Gender]!
  #  city: City
  #  cities: [City]
  #  doubleCities: [[City]]
  }
''');
    expect(parsed is Success, true);
    var user = g.types["User"]!;
    var serializer = DartSerializer(g);
    var userSerial = serializer.doSerializeTypeDefinition(user);
    var gender = g.enums["Gender"]!;
    print(userSerial);
    var fileName = "test/java/json/test.dart";
    File(fileName).writeAsStringSync('''
${userSerial}
${serializer.serializeEnumDefinition(gender)}
${serializer.serializeTypeDefinition(g.types["City"]!)}
''');

return;
    expect(
      userSerial.split("\n").map((e) => e.trim()),
      containsAllInOrder([
        "static User fromJson(Map<String, dynamic> json) {",
        "return User(",
        "id: json['id'] as String?,",
        "name: json['name'] as String,",
        "middleName: json['middleName'] as String?,",
        "dateOfBirth: json['dateOfBirth'] as int?,",
        "price: (json['price'] as num?)?.toDouble(),",
        "gender: json['gender'] == null ? null : Gender.fromJson(json['gender'] as String),",
        "gender2: Gender.fromJson(json['gender2'] as String),",
        "genders1: (json['genders1'] as List<dynamic>?)?.map((e0) => e0 == null ? null : Gender.fromJson(e0 as String)).toList(),",
        "genders2: (json['genders2'] as List<dynamic>).map((e0) => Gender.fromJson(e0 as String)).toList(),",
        "genders3: (json['genders3'] as List<dynamic>).map((e0) => e0 == null ? null : Gender.fromJson(e0 as String)).toList(),",
        "city: json['city'] == null ? null : City.fromJson(json['city'] as Map<String, dynamic>),",
        "cities: (json['cities'] as List<dynamic>?)?.map((e0) => e0 == null ? null : City.fromJson(e0 as Map<String, dynamic>)).toList(),",
        "doubleCities: (json['doubleCities'] as List<dynamic>?)?.map((e0) => (e0 as List<dynamic>?)?.map((e1) => e1 == null ? null : City.fromJson(e1 as Map<String, dynamic>)).toList()).toList()",
        ");",
        "}"
      ]),
    );
  });

  test("Java interface fromJson", () {
    final GQGrammar g = GQGrammar(
        generateAllFieldsFragments: false, autoGenerateQueries: false);

    var parsed = g.parse('''
  interface BasicEntity {
    id: ID!
  }

  type User implements BasicEntity {
    id: ID!
    name: String!
  }

  type Animal implements BasicEntity {
    id: ID!
    name: String!
    ownerId: ID!
  }
''');
    expect(parsed is Success, true);
    var user = g.interfaces["BasicEntity"]!;
    var serializer = DartSerializer(g);
    var userSerial = serializer.serializeInterface(user);
    print(userSerial);
    var fileName = "test/dart/json/test.dart";
    File(fileName).writeAsStringSync('''
${userSerial}
${serializer.serializeTypeDefinition(g.getType("User"))}
${serializer.serializeTypeDefinition(g.getType("Animal"))}
''');
  });
}
