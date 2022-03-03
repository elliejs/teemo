library teemo;

import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:teemo/src/EventSubscription.dart';

class Teemo {
  String _authKey;
  int _port;
  HttpClient _restClient;
  WebSocket _websocket;

  Map<String, List<EventSubscription>> _subscriptions;

  Teemo._create(this._authKey, this._port, this._restClient, this._websocket)
      : _subscriptions = {};

  static Future<Teemo> create() async {
    String authKey = '';
    int port = -1;

    if (Platform.isMacOS || Platform.isLinux) {
      //we can run ps aux
      ProcessResult psRes = await Process.run('ps', ['aux']);
      List<String> args = psRes.stdout.split(' ');

      for (int i = 0; i < args.length; i++) {
        List<String> keyVal = args[i].split('=');
        if (keyVal[0] == '--remoting-auth-token') {
          authKey = keyVal[1];
        } else if (keyVal[0] == '--app-port') {
          try {
            port = int.parse(keyVal[1]);
          } catch (error) {
            print('couldn\'t parse port to number');
            break;
          }
        }

        if (authKey != '' && port >= 0) break;
      }
    }

    if (authKey == '' || port == -1) print('something\'s gone wrong');

    print(authKey + ':' + port.toString());

    String cert =
        await rootBundle.loadString('packages/teemo/assets/riotgames.pem');
    print(cert);
    SecurityContext secCtx = SecurityContext();
    secCtx.setTrustedCertificatesBytes(utf8.encode(cert));

    Teemo teemo = Teemo._create(
        authKey,
        port,
        HttpClient(context: secCtx),
        await WebSocket.connect('wss://127.0.0.1:$port',
            headers: {
              'Authorization':
                  'Basic ' + utf8.fuse(base64).encode('riot:$authKey')
            },
            customClient:
                HttpClient(context: secCtx) //TODO: try teemo.rest_client
            ));
    teemo._startWebsocketListener();
    return teemo;
  }

  void _startWebsocketListener() {
    this._websocket.listen((data) {
      if (data.isEmpty) return;
      List<dynamic> jsonData = json.decode(data);
      List<EventSubscription> subscriptions =
          this._subscriptions[jsonData[1]] ?? [];
      subscriptions.forEach((sub) => sub.tasks(jsonData[2]));
    });
  }

  EventSubscription subscribe(String event,
      {EventSubscription? subscription, Handler? behavior}) {
    EventSubscription _subscription = subscription ??
        (behavior != null ? EventSubscription(behavior) : EventSubscription());
    this._subscriptions.update(event, (list) => list + [_subscription],
        ifAbsent: () => [_subscription]);
    this._websocket.add('[${EventCode.SUBSCRIBE}, "$event"]');
    return _subscription;
  }

  void unsubscribe(String event, {EventSubscription? subscription}) {
    if (subscription != null) {
      this._subscriptions[event]?.remove(subscription);
      if (this._subscriptions[event]?.isEmpty ?? true) {
        this._subscriptions.remove(event);
        this._websocket.add('[${EventCode.UNSUBSCRIBE}, "$event"]');
      }
      //WEBSOCKET DOESN'T ADD UNSUBSCRIBE IN THIS BRANCH
    } else {
      this._subscriptions.remove(event);
      this._websocket.add('[${EventCode.UNSUBSCRIBE}, $event]');
    }
  }

  List<EventSubscription> getEventSubscription(String event) {
    return this._subscriptions[event] ?? [];
  }

  void subscriptionFilterEndpoint(
      EventSubscription subscription, String endpoint,
      {Handler? behavior}) {
    behavior != null
        ? subscription.filterEndpoint(endpoint, behavior: behavior)
        : subscription.filterEndpoint(endpoint);
  }

  void subscriptionUnfilterEndpoint(
      EventSubscription subscription, String endpoint) {
    subscription.unfilterEndpoint(endpoint);
  }

  Future<JsonData> request(String method, String endpoint,
      {JsonData? body}) async {
    HttpClientRequest req = await this
        ._restClient
        .openUrl(method, Uri.parse('https://127.0.0.1:${this._port}$endpoint'));

    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.headers.set(HttpHeaders.authorizationHeader,
        'Basic ' + utf8.fuse(base64).encode('riot:${this._authKey}'));

    if (body != null) req.add(json.fuse(utf8).encode(body));

    HttpClientResponse resp = await req.close();
    return resp
        .transform(utf8.decoder)
        .join()
        .then((data) => json.decode(data));
  }

  void close() {
    this._websocket.close();
    this._restClient.close();
  }
}
