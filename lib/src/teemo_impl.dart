library teemo;

import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:teemo/src/EventSubscription.dart';

class Teemo {
  String _auth_key;
  int _port;
  HttpClient _rest_client;
  WebSocket _websocket;

  Map<String, List<EventSubscription>> _subscriptions;

  Teemo._create(this._auth_key, this._port, this._rest_client, this._websocket): _subscriptions={};

  static Future<Teemo> create() async {
    String auth_key = '';
    int port = -1;

    if (Platform.isMacOS || Platform.isLinux) { //we can run ps aux
      ProcessResult ps_res = await Process.run('ps', ['aux']);
      List<String> args = ps_res.stdout.split(' ');

      for(int i = 0; i < args.length; i++) {
        List<String> key_val = args[i].split('=');
        if (key_val[0] == '--remoting-auth-token') {
          auth_key = key_val[1];
        }
        else if (key_val[0] == '--app-port') {
          try {
            port = int.parse(key_val[1]);
          } catch (error) {
            print('couldn\'t parse port to number');
            break;
          }
        }

        if (auth_key != '' && port >= 0) break;
      }
    }

    if(auth_key == '' || port == -1) print('something\'s gone wrong');

    print(auth_key + ':' + port.toString());

    String cert = await rootBundle.loadString('packages/teemo/assets/riotgames.pem');
    print(cert);
    SecurityContext secCtx = SecurityContext();
    secCtx.setTrustedCertificatesBytes(utf8.encode(cert));

    HttpClient rest_client = HttpClient(context: secCtx);

    WebSocket websocket = await WebSocket.connect(
      'wss://127.0.0.1:${port}',
      headers: {
      'Authorization': 'Basic ' + utf8.fuse(base64).encode('riot:${auth_key}')
      },
      customClient: HttpClient(context: secCtx) //TODO: try teemo.rest_client
    );

    Teemo teemo = Teemo._create(auth_key, port, rest_client, websocket);
    teemo.start_websocket_listener();
    /* print(await teemo.request('get', '/help')); */
    EventSubscription base_sub = teemo.subscribe('OnJsonApiEvent', behavior: (data) async => print(data['eventType'] + ' ' + data['uri']));
    teemo.subscription_filter_endpoint(base_sub, '/lol-summoner/v1*', behavior: (data) async => print(data));
    return teemo;
  }

  void start_websocket_listener() {
    this._websocket.listen((data) {
      if(data.isEmpty) return;
      List<dynamic> json_data = json.decode(data);
      List<EventSubscription> subscriptions = this._subscriptions[json_data[1]] ?? [];
      subscriptions.forEach((sub) => sub.tasks(json_data[2]));
    });
  }

  EventSubscription subscribe(String event, {EventSubscription? subscription, Handler? behavior}) {
    EventSubscription _subscription = subscription ?? (behavior != null ? EventSubscription(behavior) : EventSubscription());
    this._subscriptions.update(event, (list) => list + [_subscription], ifAbsent: () => [_subscription]);
    this._websocket.add('[${EventCode.SUBSCRIBE}, "${event}"]');
    return _subscription;
  }

  void unsubscribe(String event, {EventSubscription? subscription}) {
    if(subscription != null) {
      this._subscriptions[event]?.remove(subscription);
      if (this._subscriptions[event]?.isEmpty ?? true) {
        this._subscriptions.remove(event);
        this._websocket.add('[${EventCode.UNSUBSCRIBE}, "${event}"]');
      }
      //WEBSOCKET DOESN'T ADD UNSUBSCRIBE IN THIS BRANCH
    } else {
      this._subscriptions.remove(event);
      this._websocket.add('[${EventCode.UNSUBSCRIBE}, ${event}]');
    }
  }

  List<EventSubscription> get_event_subscription(String event) {
    return this._subscriptions[event] ?? [];
  }

  void subscription_filter_endpoint(EventSubscription subscription, String endpoint, {Handler? behavior}) {
    behavior != null ? subscription.filter_endpoint(endpoint, behavior: behavior) : subscription.filter_endpoint(endpoint);
  }

  void subscription_unfilter_endpoint(EventSubscription subscription, String endpoint) {
    subscription.unfilter_endpoint(endpoint);
  }

  Future<JsonData> request(String method, String endpoint) async {
    print('getting');
    late HttpClientRequest req;
    switch (method) {
      case 'get':
      case 'GET':
        req = await this._rest_client.getUrl(Uri.parse('https://127.0.0.1:${this._port}${endpoint}'));
        break;
      default:
        return Future<JsonData>.value({'error': 'no method: ${method}'});
    }

    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.headers.set(HttpHeaders.authorizationHeader, 'Basic ' + utf8.fuse(base64).encode('riot:${this._auth_key}'));

    HttpClientResponse resp = await req.close();
    return resp.transform(utf8.decoder).join().then((data) => json.decode(data));
  }
}
