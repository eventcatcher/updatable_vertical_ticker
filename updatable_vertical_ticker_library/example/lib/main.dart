import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ipsum/ipsum.dart';
import 'package:updatable_vertical_ticker/updatable_vertical_ticker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Updatable Vertical Ticker Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Duration oneSec = Duration(milliseconds: 500);
  final double minDesktopWidth = 768;
  final double linePadding = 20;
  final double borderSpace = 64;
  final int fontMinSize = 12;
  final int fontMaxSize = 80;
  final int maxLines = 8;

  final bool useLedVariant = true;

  Orientation orientation = Orientation.portrait;
  DateTime lastUpdate = DateTime.now();
  List<String> updatableText = [];
  double width = 1280;
  double height = 768;
  double fontSize = 24.0;
  int maxWidth = 0;
  int scrollDuration = 400;
  int linePause = 1;
  int cyclePause = 2;
  int rng = -1;
  int seconds = 0;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    start();
  }

  Future<void> start() async {
    await randomUpdates();

    Timer.periodic(
      oneSec,
      (Timer t) => setState(() {
        final int value =
            rng - DateTime.now().difference(lastUpdate).inSeconds - 1;
        seconds = value > 0 ? value : 0;
      }),
    );

    initialized = true;
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  List<String> textGenerator() {
    final List<String> newTexts = ['-- Start --'];
    final int lines = random(3, 6);

    for (int i = 1; i < lines; i++) {
      final int rng = random(5, 10);
      newTexts.add(Ipsum().words(rng));
    }
    newTexts.add('-- End --');

    return newTexts;
  }

  Future<void> randomUpdates() {
    rng = rng == -1 ? 2 : random(4, 60);

    return Future.delayed(Duration(seconds: rng), () {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          setState(() {
            lastUpdate = DateTime.now();
            updatableText = textGenerator();
          });
        }
      });

      randomUpdates();
    });
  }

  List<Widget> sliders1() => [
        Row(
          children: [
            SizedBox(width: 100.0, child: Text('scrollDuration: ')),
            SizedBox(
              width: 170,
              child: Slider(
                value: scrollDuration.toDouble(),
                min: 100,
                max: 1000,
                divisions: 100,
                thumbColor: Colors.red.shade700,
                activeColor: Colors.green.shade200,
                inactiveColor: Colors.grey.shade700,
                onChanged: (double value) {
                  setState(() {
                    scrollDuration = value.floor();
                  });
                },
              ),
            ),
            Text('$scrollDuration ms'),
          ],
        ),
        if (width > minDesktopWidth) Expanded(child: SizedBox()),
        Row(
          children: [
            SizedBox(width: 100.0, child: Text('fontSize: ')),
            SizedBox(
              width: 170,
              child: Slider(
                value: fontSize,
                min: fontMinSize.toDouble(),
                max: fontMaxSize.toDouble(),
                divisions: fontMaxSize - fontMinSize,
                thumbColor: Colors.red.shade700,
                activeColor: Colors.green.shade200,
                inactiveColor: Colors.grey.shade700,
                onChanged: (double value) {
                  setState(() {
                    fontSize = value;
                  });
                },
              ),
            ),
            SizedBox(width: 80.0, child: Text('$fontSize px')),
          ],
        ),
      ];

  List<Widget> sliders2() => [
        Row(
          children: [
            SizedBox(width: 100.0, child: Text('linePause: ')),
            SizedBox(
              width: 170,
              child: Slider(
                value: linePause.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                thumbColor: Colors.red.shade700,
                activeColor: Colors.green.shade200,
                inactiveColor: Colors.grey.shade700,
                onChanged: (double value) {
                  setState(() {
                    linePause = value.floor();
                  });
                },
              ),
            ),
            Text('$linePause s'),
          ],
        ),
        if (width > minDesktopWidth) Expanded(child: SizedBox()),
        Row(
          children: [
            SizedBox(width: 100.0, child: Text('cyclePause: ')),
            SizedBox(
              width: 170,
              child: Slider(
                value: cyclePause.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                thumbColor: Colors.red.shade700,
                activeColor: Colors.green.shade200,
                inactiveColor: Colors.grey.shade700,
                onChanged: (double value) {
                  setState(() {
                    cyclePause = value.floor();
                  });
                },
              ),
            ),
            SizedBox(width: 80.0, child: Text('$cyclePause s')),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return MaterialApp(
      title: 'Updatable Vertical Ticker',
      themeMode: ThemeMode.system,
      home: Material(
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 64,
              child: OrientationBuilder(
                  builder: (BuildContext context, Orientation o) {
                orientation = o;

                return NotificationListener<SizeChangedLayoutNotification>(
                  onNotification: (notification) {
                    width = MediaQuery.of(context).size.width;
                    height = MediaQuery.of(context).size.height;
                    build(context);
                    return false;
                  },
                  child: SizeChangedLayoutNotifier(
                    child: Container(
                      padding: EdgeInsets.only(top: 16.0),
                      key: ValueKey(
                        'UpdatableVerticalTickerWrapper-${orientation == Orientation.portrait ? 'portrait' : 'landscape'}-$width',
                      ),
                      width: width - 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 150.0,
                                child: Row(
                                  children: [
                                    Text(
                                      'width: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('${width - 16}'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150.0,
                                child: Row(
                                  children: [
                                    Text(
                                      'maxWidth: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('$maxWidth'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 220.0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'orientation: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(orientation.name),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: linePadding),
                            child: SizedBox(
                              height: maxLines * 20,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'new text lines: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Flexible(
                                    child: Text(
                                      updatableText.join('\n'),
                                      maxLines: maxLines,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: linePadding),
                            child: Row(
                              children: [
                                Text(
                                  'next update: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('in $seconds seconds'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: linePadding),
                            child: width > minDesktopWidth
                                ? Row(
                                    children: sliders1(),
                                  )
                                : SizedBox(
                                    height: 100.0,
                                    child: SizedBox(
                                      height: 100.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: sliders1(),
                                      ),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: linePadding),
                            child: width > minDesktopWidth
                                ? Row(
                                    children: sliders2(),
                                  )
                                : SizedBox(
                                    height: 100.0,
                                    child: SizedBox(
                                      height: 100.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: sliders2(),
                                      ),
                                    ),
                                  ),
                          ),
                          if (width > minDesktopWidth)
                            Expanded(
                              child: SizedBox(),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: (fontMaxSize * 1.2).toDouble(),
                                  child: Center(
                                    child: Container(
                                      color: Colors.lightBlueAccent,
                                      child: initialized == true &&
                                              updatableText.isNotEmpty
                                          ? useLedVariant
                                              ? UpdatableVerticalLedTicker(
                                                  key: ValueKey(
                                                    'UpdatableVerticalTickerExamplePage-${orientation == Orientation.portrait ? 'portrait' : 'landscape'}-$width-$fontSize',
                                                  ),
                                                  texts: updatableText,
                                                  scrollDuration: Duration(
                                                      milliseconds:
                                                          scrollDuration),
                                                  linePause: Duration(
                                                      seconds: linePause),
                                                  cyclePause: Duration(
                                                      seconds: cyclePause),
                                                  getMaxWidth: (int width) {
                                                    SchedulerBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) async {
                                                      if (mounted) {
                                                        setState(() {
                                                          maxWidth = width;
                                                        });
                                                      }
                                                    });
                                                  },
                                                )
                                              : UpdatableVerticalTicker(
                                                  key: ValueKey(
                                                    'UpdatableVerticalTickerExamplePage-${orientation == Orientation.portrait ? 'portrait' : 'landscape'}-$width-$fontSize',
                                                  ),
                                                  texts: updatableText,
                                                  scrollDuration: Duration(
                                                      milliseconds:
                                                          scrollDuration),
                                                  linePause: Duration(
                                                      seconds: linePause),
                                                  cyclePause: Duration(
                                                      seconds: cyclePause),
                                                  textStyle: TextStyle(
                                                    fontFamily:
                                                        'whiteCupertino subtitle',
                                                    fontSize: fontSize,
                                                    color: Colors.black,
                                                  ),
                                                  getMaxWidth: (int width) {
                                                    SchedulerBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) async {
                                                      if (mounted) {
                                                        setState(() {
                                                          maxWidth = width;
                                                        });
                                                      }
                                                    });
                                                  },
                                                )
                                          : SizedBox(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
