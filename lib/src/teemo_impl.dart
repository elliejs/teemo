library teemo;

import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:teemo/src/EventSubscription.dart';
import 'package:teemo/src/runes.dart';

/// Teemo, the lcu interface. Use Teemo methods over [EventSubscription] methods or [Rune] methods.
class Teemo {
  String _authKey;
  int _port;
  HttpClient _restClient;
  WebSocket _websocket;

  Map<String, List<EventSubscription>> _subscriptions;

  Teemo._create(this._authKey, this._port, this._restClient, this._websocket)
      : _subscriptions = {};

  /// Asychronous constructor for Teemo. Attempts to connect to the LCU [retries] times, at [retryAfter] interval.
  ///
  /// Teemo will attempt to connect to the LCU websocket, as well as creating an HTTPS rest client instance.
  /// Teemo currently only uses the command-line arguments, not the lockfile
  static Future<Teemo> create({int retries = 5, int retryAfter = 5}) async {
    String authKey = '';
    int port = -1;

    for (int retry = 0;
        (authKey == '' || port == -1) && (retry < retries || retries == -1);
        retry++) {
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
      if (authKey != '' && port >= 0) break;
      /* print('waiting, will retry'); */
      await new Future.delayed(Duration(seconds: retryAfter));
      /* print('retrying: (${retries - retry} retries remaining)'); */
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

  /// Sends a subscription request for [event] to the LCU. When that event is recieved in the future [subscription] is launched.
  ///
  /// [behavior] and [subscription] are optional parameters for complex logic flows where you want to send multiple events through one subscription
  /// [behavior] is a shortcut to passing itself to the subscription constructor.
  /// [subscription], if null, is created and returned from the function. Else, it is returned from the function as is.
  EventSubscription subscribe(String event,
      {EventSubscription? subscription, Handler? behavior}) {
    EventSubscription _subscription = subscription ??
        (behavior != null ? EventSubscription(behavior) : EventSubscription());
    this._subscriptions.update(event, (list) => list + [_subscription],
        ifAbsent: () {
      this._websocket.add('[${EventCode.SUBSCRIBE}, "$event"]');
      return [_subscription];
    });
    return _subscription;
  }

  /// Unsubscribes [event]. If [subscription] is provided, only that subscription is removed from the event. Otherwise ALL subscriptions are removed and the event is unsubscribed at the LCU level.
  /// If the last subscription is removed from an event, it is unsubscribed at the LCU level.
  /// It is possible to unsubscribe to events that were never subscribed to. This is ignored by the LCU.
  void unsubscribe(String event, {EventSubscription? subscription}) {
    if (subscription != null) {
      this._subscriptions[event]?.remove(subscription);
      if (!(this._subscriptions[event]?.isEmpty ?? true)) {
        //WEBSOCKET DOESN'T ADD UNSUBSCRIBE IN THIS BRANCH
        return;
      }
    }
    this._subscriptions.remove(event);
    this._websocket.add('[${EventCode.UNSUBSCRIBE}, $event]');
  }

  /// Returns the [List<EventSubscription>] from Teemo's database of all subscriptions attached to [event].
  List<EventSubscription> getEventSubscription(String event) {
    return this._subscriptions[event] ?? [];
  }

  /// Adds a special callback to [subscription] which triggers when an event with the uri [endpoint] gets sent from the LCU.
  /// If no [behavior] is provided, the subscription's default handler is used. (This is effectively the same as never calling this function, however it is valid.)
  void subscriptionFilterEndpoint(
      EventSubscription subscription, String endpoint,
      {Handler? behavior}) {
    behavior != null
        ? subscription.filterEndpoint(endpoint, behavior: behavior)
        : subscription.filterEndpoint(endpoint);
  }

  /// Removes the special behavior endpoint from the subscription. If absent, while valid, nothing happens.
  void subscriptionUnfilterEndpoint(
      EventSubscription subscription, String endpoint) {
    subscription.unfilterEndpoint(endpoint);
  }

  /// Used to send GET, POST, HEAD, etc... requests.
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
        .then((String data) => json.decode(data.isEmpty ? '{}' : data));
  }

  /// Attempts to close Teemo's websocket and rest client. Call before exiting the app.
  void close() {
    this._websocket.close();
    this._restClient.close();
  }

  /// Sets current rune page using either ids or [Rune] static members. If an invalid page is requested, nothing happens.
  void setCurrentRunePage(
      int keystone,
      int primary1,
      int primary2,
      int primary3,
      int secondary1,
      int secondary2,
      int perk1,
      int perk2,
      int perk3,
      {String name = 'Teemo Created Page'}) async {
    if (!Rune.validate(keystone, primary1, primary2, primary3, secondary1,
        secondary2, perk1, perk2, perk3)) return;

    JsonData currentPage =
        await this.request('GET', '/lol-perks/v1/currentpage');
    /* print(currentPage); */
    currentPage = await this
        .request('DELETE', '/lol-perks/v1/pages/${currentPage['id']}');
    /* print(currentPage); */
    currentPage = await this.request('POST', '/lol-perks/v1/pages', body: {
      "name": name,
      "primaryStyleId": Rune.treeId(keystone),
      "subStyleId": Rune.treeId(secondary1),
      "selectedPerkIds": [
        keystone,
        primary1,
        primary2,
        primary3,
        secondary1,
        secondary2,
        perk1,
        perk2,
        perk3
      ],
      "current": true
    });
    /* print(currentPage); */
  }
}
