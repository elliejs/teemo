typedef JsonData = Map<String, dynamic>;

/// The type of ALL Teemo behavior callbacks. an asynchronous void function which consumes JSON.
typedef Handler = Future<void> Function(JsonData data);

/// The three LCU ids for requesting levels of activity on events.
class EventCode {
  static const int SUBSCRIBE = 5;
  static const int UNSUBSCRIBE = 6;
  static const int RESPONSE = 8;
}

/// EventSubscription methods can be used to manipulate subscriptions, however Teemo provides all the necessary abstraction.
class EventSubscription {
  Map<String, List<Handler>> _registeredUris = {};
  Map<String, List<Handler>> _registeredPaths = {};
  Handler _defaultBehavior;

  static Future<void> _defaultBehaviorImpl(JsonData data) async {
    print(data);
  }

  /// Default constructor uses the private defaultbehavior handler for all unhandled endpoints, which is to print all JSON consumed.
  /// Provide a [Handler] argument to override the subscription's default behavior on all incoming messages.
  EventSubscription(
      [this._defaultBehavior = EventSubscription._defaultBehaviorImpl]);

  /// filters an endpoint to be consumed with special behavior. if [endpoint] ends in '*', all URIs starting with endpoint are consumed by this filter.
  void filterEndpoint(String endpoint,
      {Handler behavior = EventSubscription._defaultBehaviorImpl}) {
    if (endpoint.endsWith('*')) {
      //then this is a path and we want to glob match
      this._registeredPaths.update(endpoint.substring(0, endpoint.length - 1),
          (list) => list + [behavior],
          ifAbsent: () => [behavior]);
    } else {
      this._registeredUris.update(endpoint, (list) => list + [behavior],
          ifAbsent: () => [behavior]);
    }
  }

  /// unfilters an endpoint. To unfilter an endpoint which ended in '*', provide the '*' here too.
  void unfilterEndpoint(String endpoint) {
    if (endpoint.endsWith('*')) {
      //then this is a path and we want to glob match
      this._registeredPaths.remove(endpoint.substring(0, endpoint.length - 1));
    } else {
      this._registeredUris.remove(endpoint);
    }
  }

  /// A mostly private method for Teemo to gather all handlers which match the incoming [data] from the LCU server.
  List<Future<void>> tasks(JsonData data) {
    List<Handler> tasks = [];

    this._registeredPaths.forEach((key, value) =>
        {data['uri'].startsWith(key) ? tasks.addAll(value) : {}});

    tasks.addAll(this._registeredUris[data['uri']] ?? []);

    if (tasks.isEmpty) tasks.add(this._defaultBehavior);
    return tasks.map((e) => e(data)).toList();
  }
}
