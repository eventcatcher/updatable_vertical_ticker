# Updatable Vertical Ticker

A flutter widget for a smoothly scrolling vertical text ticker that integrates text updates cleanly so that scrolling is glitch-free and uninterrupted. The main feature is that all text updates take place in the area of the text buffer that is not yet visible, so that the text does not disrupt (glitch effect) during display.

https://github.com/user-attachments/assets/4f565e1e-d072-4c83-a770-6a9103c73a0b


## Video of LED Variant
https://github.com/user-attachments/assets/2580b18d-c750-44c0-900b-6a5a41250a27

# Getting Started

Add this to your package's `pubspec.yaml` file for local testing:

```yaml
dependencies:
  updatable_vertical_ticker:
    path: path/to/updatable_vertical_ticker_library
```

or if loading from pub.dev:

```yaml
dependencies:
  updatable_vertical_ticker: ^1.1.1
```

or (better) run this command:
```
$ flutter pub add updatable_vertical_ticker
```

# Usage 

Then you just have to import the package with
```
import 'package:updatable_vertical_ticker/updatable_vertical_ticker.dart';
```

# Properties

The package has a few properties to configure, it's simple.

```
List<String> texts;                     // List of texts to scroll through.
Duration scrollDuration;                // Duration for scrolling from one line to the next.
Duration linePause;                     // Delay before the next line starts scrolling
Duration cyclePause;                    // Delay before the next cycle starts (blank time)
TextStyle textStyle;                    // Text style used for rendering.
Function(int width)? getMaxWidth;       // optionally callback to get max width of the text.
VerticalTickerItemBuilder? itemBuilder  // optionally custom itemBuilder.
```

# Example
This is a small example: 
```
import 'package:flutter/material.dart';
import 'package:updatable_vertical_ticker/updatable_vertical_ticker.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => ExamplePageState();
}

class ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          color: Colors.lightBlueAccent,
          width: 800.0,
          child: UpdatableVerticalTicker(
            key: ValueKey(
              'ExamplePage',
            ),
            texts: [
              'This is a UpdatableVerticalTicker Demo',
              'A flutter widget for a smoothly scrolling text ticker',
              'Scrolling is glitch-free and uninterrupted',
            ],
            scrollDuration: Duration(milliseconds: 400),
            linePause: Duration(seconds: 1),
            cyclePause: Duration(seconds: 2),
            textStyle: TextStyle(
              fontFamily: 'Arial',
              fontSize: 24.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
```

But you need a little bit more if you want to update the text automatically.
First of all, you need a source of text which updates from time to time.
This variable is required for the connection with the texts property.

In my example, I have randomly timed the actualization of texts data with a Timer.periodic, which generates demo text (lorem ipsum) with random word lengths.
The UpdatableVerticalTicker will rebuild when alignment, width or font size changes.
To do this, you must wrap the UpdatableVerticalTicker with OrientationBuilder, SizeChangedLayoutNotifier and a ValueKey with this data as the key for UpdatableVerticalTicker.

A nice example how to do this can you find on my Github Page (part of updatable_vertical_ticker repo) here: https://github.com/eventcatcher/updatable_vertical_ticker/tree/main/updatable_vertical_ticker_sample

A demo video of how the ticker can look like, you can find here on my Github page: https://github.com/eventcatcher/updatable_vertical_ticker?tab=readme-ov-file#updatable-vertical-ticker-project

# Feedback

Please feel free to [give me any feedback](https://github.com/eventcatcher/updatable_vertical_ticker/issues) helping support this plugin !