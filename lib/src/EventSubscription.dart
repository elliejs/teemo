typedef JsonData = Map<String, dynamic>;
typedef Handler = Future<void> Function(JsonData data);

class EventCode {
  static const int SUBSCRIBE = 5;
  static const int UNSUBSCRIBE = 6;
  static const int RESPONSE = 8;
}

class EventSubscription {
  Map<String, List<Handler>> _registeredUris = {};
  Map<String, List<Handler>> _registeredPaths = {};
  Handler _defaultBehavior;

  static Future<void> _defaultBehaviorImpl(JsonData data) async {
    print(data);
  }

  EventSubscription(
      [this._defaultBehavior = EventSubscription._defaultBehaviorImpl]);

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

  void unfilterEndpoint(String endpoint) {
    if (endpoint.endsWith('*')) {
      //then this is a path and we want to glob match
      this._registeredPaths.remove(endpoint.substring(0, endpoint.length - 1));
    } else {
      this._registeredUris.remove(endpoint);
    }
  }

  List<Future<void>> tasks(JsonData data) {
    List<Handler> tasks = [];

    this._registeredPaths.forEach((key, value) =>
        {data['uri'].startsWith(key) ? tasks.addAll(value) : {}});

    tasks.addAll(this._registeredUris[data['uri']] ?? []);

    if (tasks.isEmpty) tasks.add(this._defaultBehavior);
    return tasks.map((e) => e(data)).toList();
  }
}
