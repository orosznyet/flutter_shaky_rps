import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shaky_rps/lang.dart';
import 'package:shaky_rps/controllers/shaker.dart';
import 'package:shaky_rps/ui/screen/game.dart';
import 'package:shaky_rps/ui/screen/info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  var shaker = new Shaker(cooldown: Duration(seconds: 1));
  await shaker.init();

  return runApp(ShakingRpsApp(shaker));
}

class ShakingRpsApp extends StatefulWidget {
  @override
  ShakingRpsApp(this.shaker, {Key key}) : super(key: key);

  final Shaker shaker;

  @override
  _ShakingRpsAppState createState() => _ShakingRpsAppState();
}

class _ShakingRpsAppState extends State<ShakingRpsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 1), () {
      widget.shaker.updateHasShakeSupport();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        widget.shaker.stop();
        break;
      case AppLifecycleState.resumed:
        widget.shaker.init();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(builder: (_) => widget.shaker)],
      child: MaterialApp(
        title: 'Shakey RPS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        supportedLocales: [
          Locale('en', 'US'),
          Locale('hu', 'HU'),
        ],
        localizationsDelegates: [
          Lang.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => new Game(),
          '/info': (BuildContext context) => new Info(),
        },
        initialRoute: '/',
      ),
    );
  }
}
