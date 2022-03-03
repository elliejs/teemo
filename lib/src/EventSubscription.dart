typedef JsonData = Map<String, dynamic>;
typedef Handler = Future<void> Function(JsonData data);

class EventCode {
  static const int SUBSCRIBE   = 5;
  static const int UNSUBSCRIBE = 6;
  static const int RESPONSE    = 8;
}

class EventSubscription {
  Map<String, List<Handler>> _registered_uris = {};
  Map<String, List<Handler>> _registered_paths = {};
  Handler default_behavior;

  static Future<void> _default_behavior_impl(JsonData data) async {
    print(data);
  }

  EventSubscription([this.default_behavior=EventSubscription._default_behavior_impl]);

  void filter_endpoint(String endpoint, {Handler behavior=EventSubscription._default_behavior_impl}) {
    if (endpoint.endsWith('*')) { //then this is a path and we want to glob match
      this._registered_paths.update(endpoint.substring(0, endpoint.length - 1), (list) => list + [behavior], ifAbsent: () => [behavior]);
    } else {
      this._registered_uris.update(endpoint, (list) => list + [behavior], ifAbsent: () => [behavior]);
    }
  }

  void unfilter_endpoint(String endpoint) {
    if (endpoint.endsWith('*')) { //then this is a path and we want to glob match
      this._registered_paths.remove(endpoint.substring(0, endpoint.length - 1));
    } else {
      this._registered_uris.remove(endpoint);
    }
  }

  List<Future<void>> tasks(JsonData data) {
    List<Handler> tasks = [];

    this._registered_paths.forEach((key, value) => {
      data['uri'].startsWith(key)
      ? tasks.addAll(value)
      : {}
    });

    tasks.addAll(this._registered_uris[data['uri']] ?? []);

    if (tasks.isEmpty) tasks.add(this.default_behavior);
    return tasks.map((e) => e(data)).toList();
  }
}
