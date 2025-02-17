import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';
import 'package:shaky_rps/controllers/shaker.dart';
import 'package:shaky_rps/ui/screen/info.dart';
import 'package:shaky_rps/ui/transition/reveal.dart';
import 'package:shaky_rps/ui/widget/shake_randomizer.dart';
import 'package:shaky_rps/ui/widget/source_selector.dart';
import 'package:shaky_rps/vars/shake_set.dart';
import 'package:shaky_rps/ui/widget/rotating_background.dart';

class Game extends StatefulWidget {
  @override
  _Game createState() => _Game();
}

class _Game extends State<Game> {
  ShakeItemSet _gameSet = ShakeGameSets.classic;
  Shaker _shaker;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    _shaker = Provider.of<Shaker>(context);
    _shaker.removeListener(onShakerStateChange);
    _shaker.addListener(onShakerStateChange);

    return Stack(overflow: Overflow.visible, children: [
      RotatingBackground(),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            // color: const Color(0xff27364e),
            width: deviceSize.width,
            child: Column(
              children: [
                SafeArea(
                  child: Container(
                    width: deviceSize.width,
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.only(right: 5, bottom: 50),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: Icon(FontAwesomeIcons.info),
                      onPressed: () => openHelp(context),
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(child: ShakeRandomizer(_gameSet)),
                SourceSelector(
                  key: ValueKey('source_selector'),
                  mode: _gameSet,
                  onChanged: (mode) => onGameSetChange(mode),
                )
              ],
            )),
        // bottomNavigationBar: _buildBottom(),
      ),
      _shaker?.status != ShakeStatus.ACTIVE
          ? Container()
          : _buildFlashingOverlay(deviceSize),
    ]);
  }

  void onShakerStateChange() {
    setState(() {
      /// This will schedule a redraw
    });
  }

  void openHelp(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double diagonal =
        math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));

    Navigator.push(
      context,
      RevealRoute(
        page: Info(),
        centerIn: AnimationCenter(alignment: Alignment.topRight),
        centerOut: AnimationCenter(alignment: Alignment.topLeft),
        maxRadius: diagonal,
      ),
    );
  }

  /// This overlay will be shown if the phone is shaking.
  /// Otherwise should not be applied to the widget tree.
  Widget _buildFlashingOverlay(Size size) {
    return Container(
      color: RandomColor().randomColor(
          colorSaturation: ColorSaturation.highSaturation,
          colorBrightness: ColorBrightness.light
          // colorHue: ColorHue.multiple(colorHues: [ColorHue.red, ColorHue.blue]),
          ),
      child: SizedBox(width: size.width, height: size.height),
    );
  }

  /// Event handler for the game set selector.0000
  onGameSetChange(ShakeItemSet mode) {
    setState(() {
      _gameSet = mode;
    });
  }
}
