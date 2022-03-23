# Teemo

Teemo is a dart library which provides an intuitive interface to the League of Legends LCU API

## Installing Teemo
Teemo is hosted on [pub.dev](pub.dev), which means you can get it with Flutter's built in `pub add` command.

```bash
$ flutter pub add teemo
```
This will add a line to your [pubspec.yaml]:
```
dependencies:
  teemo: ^0.2.1
```
Note: 0.2.1 was the current version at time of writing. It will show up in your pubspec as whatever is the most current version.

If you do not see this in your pubspec.yaml, run:
```bash
$ flutter pub get
```

Congratulations, you can now import Teemo into your Dart code with:
```dart
import 'package:teemo/teemo.dart';
```

## Using Teemo
Method documentation to help you with your development can be found [here](https://pub.dev/documentation/teemo/latest/teemo/teemo-library.html).


Since Teemo is asynchronous, you will need to use it inside asynchronous widgets like `FutureBuilder`. An example is below, and a working code sample can be found at [example/lib/main.dart](example/lib/main.dart).

```dart
FutureBuilder<Teemo>(
  future: _teemo, // a previously-obtained Future<String> or null
  builder: (BuildContext context, AsyncSnapshot<Teemo> snapshot) {
    List<Widget> children;
    if (snapshot.hasData) {
      children = <Widget>[
        OutlinedButton(
          onPressed: () {
            snapshot.data?.setCurrentRunePage(
                Rune.Conqueror,
                Rune.Triumph,
                Rune.LegendTenacity,
                Rune.LastStand,
                Rune.Transcendence,
                Rune.GatheringStorm,
                Rune.AdaptiveForcePerk,
                Rune.AdaptiveForcePerk,
                Rune.HealthPerk,
                name: 'Riven');
          },
          child: Text("Send Me To A Custom Lobby"),
        )
      ];
    } else {
      children = const <Widget>[
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Awaiting result...'),
        )
      ];
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  },
)
```

## Understanding Events and Subscriptions
### Q: What are events?
### A:
Events are server side concepts. There are a many events you can subscribe to.
They are names for many different api updates that fall under their umbrella.
Use - request('get', '/help') - to get a JSON blob with a list of all possible events to subscribe to.
When events are triggered, they send the new data to willump.
Each update is of an endpoint underneath Event umbrella.
TL;DR
  Events are names for groups of endpoints.
  when an endpoint in an event changes, you get sent the new data for that endpoint.

### Q: How do I use events?
### A:
Subscribe to an event to begin receiving its messages. The default_handler argument
runs every time a message is received and not otherwise handled. You don't need to
supply a default_handler. If you don't the automatic behavior is to log it as info.

### Q: How do I interact with messages coming from events?
### A:
Messages come from endpoints. To catch an endpoint for special processing,
use subscription_filter_endpoint from willump, or filter_endpoint from the subscription.
these methods make the 'handler' argument run instead of the event's default handler.

###	REMEMBER TO MAKE EVENT HANDLER METHODS ASYNC

## Using the Websocket
Using the websocket is as simple as subscribing to an event and possibly filtering endpoints. Due to the callback nature of this architecture, all websocket actions are automatically called when the LCU sends a message that should be handled by a subscription or subscription filter.

## Making RESTful requests
Making rest requests is as simple as:
```Dart
Teemo teemo = await Teemo.create();
await teemo.request('POST', '/lol-lobby/v2/lobby', body: {
      "customGameLobby": {
        "configuration": {
          "gameMode": "PRACTICETOOL",
          "gameMutator": "",
          "gameServerRegion": "",
          "mapId": 11,
          "mutators": {"id": 1},
          "spectatorPolicy": "AllAllowed",
          "teamSize": 5
        },
        "lobbyName":"Name",
        "lobbyPassword":null
      },
      "isCustom":true
    });
```
This code snippet will send the user to a custom practice tool lobby.

---
*Teemo isn't endorsed by Riot Games and doesn't reflect the views or opinions of Riot Games or anyone officially involved in producing or managing Riot Games properties. Riot Games, and all associated properties are trademarks or registered trademarks of Riot Games, Inc.*
