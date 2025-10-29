import 'package:retrofit_graphql/src/code_gen_utils.dart';
import 'package:retrofit_graphql/src/constants.dart';
import 'package:retrofit_graphql/src/extensions.dart';
import 'package:retrofit_graphql/src/gq_grammar.dart';
import 'package:retrofit_graphql/src/model/gq_queries.dart';
import 'package:retrofit_graphql/src/model/gq_token.dart';
import 'package:retrofit_graphql/src/model/gq_type.dart';
import 'package:retrofit_graphql/src/serializers/gq_client_serilaizer.dart';
import 'package:retrofit_graphql/src/serializers/gq_serializer.dart';
import 'package:retrofit_graphql/src/serializers/graphq_serializer.dart';

class JavaClientSerializer extends ClientSerilaizer {
  final GQGrammar _grammar;
  final codeGenUtils = JavaCodeGenUtils();
  static const clientName = 'GQClient';
  final GraphqSerializer gqlSerializer;

  JavaClientSerializer(this._grammar, GqSerializer serializer)
      : gqlSerializer = GraphqSerializer(_grammar, false),
        super(serializer);

  @override
  String generateClient(String importPrefix) {
    var imports = serializeImports(_grammar, importPrefix);

    var buffer = StringBuffer();
    for (var i in [
      JavaImports.map,
      JavaImports.hashMap,
      JavaImports.list,
      JavaImports.collectors,
      JavaImports.arrays,
    ]) {
      buffer.writeln('import ${i};');
    }
    buffer.writeln(imports);

    buffer.writeln(codeGenUtils.createClass(className: clientName, statements: [
      'final Map<String, String> _fragmMap = new HashMap<>();',
      'final GQClientAdapter adapter;',
      'final GQJsonEncoder encoder;',
      'final GQJsonDecoder decoder;',
      if (_grammar.hasQueries) 'public final ${classNameFromType(GQQueryType.query)} queries;',
      if (_grammar.hasMutations)
        'public final ${classNameFromType(GQQueryType.mutation)} mutations;',
      if (_grammar.hasSubscriptions)
        'public final ${classNameFromType(GQQueryType.subscription)} subscriptions;',
      codeGenUtils.createMethod(
        returnType: "public",
        methodName: clientName,
        arguments: [
          _adapterDeclaration(),
          if (_grammar.hasSubscriptions) 'GQWebSocketAdapter wsAdapter'
        ],
        statements: [
          'this.adapter = adapter;',
          'this.encoder = encoder;',
          'this.decoder = decoder;',
          if (_grammar.hasQueries)
            "queries = new ${classNameFromType(GQQueryType.query)}(adapter, _fragmMap, encoder, decoder);",
          if (_grammar.hasMutations)
            "mutations = new ${classNameFromType(GQQueryType.mutation)}(adapter, _fragmMap, encoder, decoder);",
          if (_grammar.hasSubscriptions)
            "subscriptions = new ${classNameFromType(GQQueryType.subscription)}(wsAdapter, _fragmMap, encoder, decoder);",
          ..._grammar.fragments.values.map((value) =>
              '_fragmMap.put("${value.tokenInfo}", "${gqlSerializer.serializeFragmentDefinitionBase(value)}");'),
        ],
      ),
      '',
      ...GQQueryType.values
          .map((e) => generateQueriesClassByType(e))
          .where((e) => e != null)
          .map((e) => e!)
    ]));

    buffer.writeln(serializeSubscriptions().ident());
    return buffer.toString();
  }

  String _adapterDeclaration() {
    return 'GQClientAdapter adapter, GQJsonEncoder encoder, GQJsonDecoder decoder';
  }

  String? generateQueriesClassByType(GQQueryType type) {
    var queries = _grammar.queries.values;
    var queryList =
        queries.where((element) => element.type == type && _grammar.hasQueryType(type)).toList();
    if (queryList.isEmpty) {
      return null;
    }

    return codeGenUtils
        .createClass(staticClass: true, className: classNameFromType(type), statements: [
      ...declareAdapter(type),
      "final Map<String, String> fragmentMap;",
      "final GQJsonEncoder encoder;",
      "final GQJsonDecoder decoder;",
      codeGenUtils.createMethod(
          returnType: 'public',
          methodName: classNameFromType(type),
          arguments: _declareConstructorArgs(type),
          statements: [
            'this.adapter = adapter;',
            'this.fragmentMap = fragmentMap;',
            'this.encoder = encoder;',
            'this.decoder = decoder;',
            if (type == GQQueryType.subscription) '_handler = _SubscriptionHandler(adapter);',
          ]),
      ...queryList.map((e) => queryToMethod(e))
    ]);
  }

  List<String> _declareConstructorArgs(GQQueryType type) {
    if (type == GQQueryType.subscription) {
      return [
        'GQWebSocketAdapter adapter',
        'Map<String, String> fragmentMap',
        'GQJsonEncoder encoder',
        'GQJsonDecoder decoder',
      ];
    }
    return [
      'GQClientAdapter adapter',
      'Map<String, String> fragmentMap',
      'GQJsonEncoder encoder',
      'GQJsonDecoder decoder',
    ];
  }

  List<String> declareAdapter(GQQueryType type) {
    switch (type) {
      case GQQueryType.query:
      case GQQueryType.mutation:
        return ["final GQClientAdapter adapter;"];
      case GQQueryType.subscription:
        return ["final _SubscriptionHandler _handler;", "final GQWebSocketAdapter adapter;"];
    }
  }

  String queryToMethod(GQQueryDefinition def) {
    return codeGenUtils.createMethod(
        returnType: 'public ${returnTypeByQueryType(def)}',
        methodName: def.tokenInfo.token,
        arguments: getArguments(def),
        statements: [
          'String operationName = "${def.tokenInfo}";',
          "List<String> fragsValues = Arrays.asList(${def.fragments(_grammar).map((e) => 'fragmentMap.get("${e.token}")').join(", ")});",
          'String query = "${gqlSerializer.serializeQueryDefinition(def)} " + String.join(" ", fragsValues);',
          generateVariables(def),
          "GQPayload payload = GQPayload.builder().query(query).operationName(operationName).variables(variables).build();",
          _serializeAdapterCall(def)
        ]);
  }

  String generateVariables(GQQueryDefinition def) {
    var buffer = StringBuffer("Map<String, Object> variables = new HashMap<String, Object>();");
    buffer.writeln();
    def.arguments
        .map((e) =>
            'variables.put("${e.dartArgumentName}", ${_serializeArgumentValue(def, e.token)});')
        .forEach(buffer.writeln);

    return buffer.toString();
  }

  String _serializeAdapterCall(GQQueryDefinition def) {
    if (def.type == GQQueryType.subscription) {
      return """
return _handler.handle(payload).map((e) => ${def.getGeneratedTypeDefinition().tokenInfo.token}.fromJson(e));
    """
          .trim()
          .ident();
    }
    return [
      "String encodedPayload = encoder.encode(payload);",
      "String responseText = adapter.execute(encodedPayload);",
      "Map<String, Object> decodedResponse = decoder.decode(responseText);",
      codeGenUtils
          .ifStatement(condition: 'decodedResponse.containsKey("error")', ifBlockStatements: [
        'throw new RuntimeException(decodedResponse.get("error").toString());'
      ], elseBlockStatements: [
        'return ${def.getGeneratedTypeDefinition().tokenInfo}.fromJson((Map<String, Object>)decodedResponse.get("data"));'
      ])
    ].join("\n");
  }

  String _serializeArgumentValue(GQQueryDefinition def, String argName) {
    var arg = def.findByName(argName);
    return _callToJson(arg.dartArgumentName, arg.type);
  }

  String _callToJson(String argName, GQType type) {
    if (_grammar.inputTypeRequiresProjection(type)) {
      if (type.isList) {
        return "$argName${_getNullableText(type)}.map((e) => ${_callToJson("e", type.inlineType)}).toList()";
      } else {
        return "$argName${_getNullableText(type)}.toJson()";
      }
    }
    if (_grammar.isEnum(type.token)) {
      if (type.isList) {
        return "$argName${_getNullableText(type)}.map((e) => ${_callToJson("e", type.inlineType)}).toList()";
      } else {
        return "$argName${_getNullableText(type)}.toJson()";
      }
    } else {
      return argName;
    }
  }

  String _getNullableText(GQType type) {
    if (type.nullable) {
      return "?";
    }
    return "";
  }

  List<String> getArguments(GQQueryDefinition def) {
    if (def.arguments.isEmpty) {
      return [];
    }
    return def.arguments
        .map((e) => "${serializer.serializeType(e.type, false)} ${e.dartArgumentName}")
        .toList();
  }

  String returnTypeByQueryType(GQQueryDefinition def) {
    var gen = def.getGeneratedTypeDefinition();

    if (def.type == GQQueryType.subscription) {
      return "void";
    }
    return gen.tokenInfo.token;
  }

  String serializeSubscriptions() {
    if (!_grammar.hasSubscriptions) {
      return "";
    }
    return """
$_subscriptionHandler
$_streamSink
""";
  }

  String get fileExtension => '.java';

  @override
  Set<GQToken> getImportDependecies(GQGrammar g) {
    var result = {...super.getImportDependecies(g)};
    result.addAll(
        ['GQJsonEncoder', 'GQJsonDecoder', 'GQClientAdapter'].map((e) => g.getTypeByName(e)!));
    var adapter = g.getTokenByKey('GQWebSocketAdapter');
    if (adapter != null) {
      result.add(adapter);
    }
    return result;
  }
}

const _subscriptionHandler = """

static class GraphqlWsMessageTypes {
  /// Client initializes connection.
  /// Example: { "type": "connection_init", "payload": { "authToken": "abc123" } }
  public static final String connectionInit = "connection_init";

  /// Server acknowledges connection.
  /// Example: { "type": "connection_ack" }
  public static final String connectionAck = "connection_ack";

  /// Client subscribes to an operation.
  /// Example:
  /// {
  ///   "id": "1",
  ///   "type": "subscribe",
  ///   "payload": { "query": "...", "variables": {} }
  /// }
  public static final String subscribe = 'subscribe';

  /// Client or server pings for keep-alive.
  /// Example: { "type": "ping", "payload": {} }
  public static final String ping = "ping";

  /// Response to ping.
  /// Example: { "type": "pong" }
  public static final String pong = "pong";

  /// Server sends subscription data.
  /// Example:
  /// {
  ///   "id": "1",
  ///   "type": "next",
  ///   "payload": { "data": { "newMessage": { "id": "42", "content": "Hi" } } }
  /// }
  public static final String next = "next";

  /// Server sends a fatal error for a subscription.
  /// Example: { "id": "1", "type": "error", "payload": { "message": "Validation failed" } }
  public static final String error = "error";

  /// Client or server completes subscription.
  /// Example: { "id": "1", "type": "complete" }
  public static final String complete = "complete";
}


class _SubscriptionHandler {
  static const hexDigits = '0123456789abcdef';
  final _random = Random();
  final Map<String, StreamController<Map<String, dynamic>>> _map = {};
  final Map<String, StreamSubscription> _subs = {};
  final GQWebSocketAdapter adapter;

  final connectionInit = jsonEncode(GQSubscriptionErrorMessage(type: GraphqlWsMessageTypes.connectionInit).toJson());
  final pingMessage = jsonEncode(GQSubscriptionErrorMessage(type: GraphqlWsMessageTypes.ping).toJson());
  final pongMessage = jsonEncode(GQSubscriptionErrorMessage(type: GraphqlWsMessageTypes.pong).toJson());

  _SubscriptionHandler(this.adapter);

  var _ackStatus = GQAckStatus.none;

  Stream<String> get _onMessageStream {
    var stream = adapter.onMessageStream;
    if (stream.isBroadcast) {
      return stream;
    }
    return stream.asBroadcastStream();
  }

  Future<_StreamSink> _initWs() async {
    switch (_ackStatus) {
      case GQAckStatus.none:
        {
          _ackStatus = GQAckStatus.progress;
          await adapter.onConnectionReady();
          adapter.sendMessage(connectionInit);
          return _onMessageStream.map((event) {
            var decoded = jsonDecode(event);
            if (decoded is Map<String, dynamic>) {
              return GQSubscriptionMessage.fromJson(decoded);
            } else {
              return GQSubscriptionErrorMessage(payload: decoded);
            }
          }).map((event) {
            switch (event.type) {
              case GraphqlWsMessageTypes.connectionAck:
                _ackStatus = GQAckStatus.acknoledged;
                return _StreamSink(sendMessage: adapter.sendMessage, stream: _onMessageStream);
              case GraphqlWsMessageTypes.error:
                _ackStatus = GQAckStatus.none;
                throw (event as GQSubscriptionErrorMessage).payload!;
              default:
                return _StreamSink(sendMessage: adapter.sendMessage, stream: _onMessageStream);
            }
          }).first;
        }
      case GQAckStatus.progress:
      case GQAckStatus.acknoledged:
        return _StreamSink(sendMessage: adapter.sendMessage, stream: _onMessageStream);
    }
  }

  StreamController<Map<String, dynamic>> _createStremController(String uuid) {
    var controller = StreamController<Map<String, dynamic>>(
      onCancel: () {
        _removeController(uuid);
      },
    );
    _map[uuid] = controller;
    return controller;
  }

  Stream<Map<String, dynamic>> handle(GQPayload pl) {
    String uuid = _generateUuid();
    var controller = _createStremController(uuid);

    _initWs().then((streamSink) {
      var sub = streamSink.stream
          .map(_parseEvent)
          .where((event) => event.id == uuid)
          .listen((msg) => _handleMessage(msg, uuid));
      _subs[uuid] = sub;
      var message = GQSubscriptionMessage(
          id: uuid,
          type: GraphqlWsMessageTypes.subscribe,
          payload: GQSubscriptionPayload(
            query: pl.query,
            operationName: pl.operationName,
            variables: pl.variables,
          ));

      streamSink.sendMessage(json.encode(message.toJson()));
    });

    return controller.stream;
  }

  GQSubscriptionErrorMessageBase _parseEvent(String event) {
    var map = jsonDecode(event);
    var payload = map["payload"];
    GQSubscriptionErrorMessageBase result;
    if (payload is Map) {
      result = GQSubscriptionMessage.fromJson(map);
    } else {
      result = GQSubscriptionErrorMessage.fromJson(map);
    }
    return result;
  }

  void _sendPingMessage() {
    adapter.sendMessage(pingMessage);
  }

  void _sendPongMessage() {
    adapter.sendMessage(pongMessage);
  }

  void _handleMessage(GQSubscriptionErrorMessageBase msg, String uuid) {
    var controller = _map[uuid]!;
    switch (msg.type!) {
      case GraphqlWsMessageTypes.ping:
        _sendPingMessage();
        break;
      case GraphqlWsMessageTypes.pong:
        _sendPongMessage();
        break;
      case GraphqlWsMessageTypes.next:
        controller.add((msg as GQSubscriptionMessage).payload!.data!);
        break;
      case GraphqlWsMessageTypes.complete:
        _removeController(uuid);
        break;
      case GraphqlWsMessageTypes.error:
        var errorMsg = msg as GQSubscriptionErrorMessage;
        var ctrl = _map[uuid]!;
        ctrl.addError(errorMsg.payload as Object);
        _removeController(uuid);
        break;
      default:
    }
  }

  void _removeController(String uuid) {
    _subs.remove(uuid)?.cancel();
    _map.remove(uuid)?.close();
    if (_map.isEmpty) {
      adapter.close();
      _ackStatus = GQAckStatus.none;
    }
  }

  String _generateRandomString(int length) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final randomIndex = _random.nextInt(hexDigits.length);
      buffer.write(hexDigits[randomIndex]);
    }
    return buffer.toString();
  }

  String _generateUuid([String separator = "-"]) {
    return [
      _generateRandomString(8),
      _generateRandomString(4),
      _generateRandomString(4),
      _generateRandomString(4),
      _generateRandomString(12),
    ].join(separator);
  }
}

""";

const _streamSink = """
class _StreamSink {
  final Function(String) sendMessage;
  final Stream<String> stream;

  _StreamSink({required this.sendMessage, required this.stream});
}
""";
