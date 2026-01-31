# Updatable Vertical Ticker Sample

Example App for Flutter package UpdatableVerticalTicker

# Usage

First of all, you need a source of text lines which updates from time to time.
This variable is required for the connection with the texts property.

In my example, I have randomly timed the actualization of texts data with a Timer.periodic, which generates demo text (lorem ipsum) with random word lengths.
The UpdatableVerticalTicker will rebuild when orientation, width or font size changes.
To do this, you must wrap the UpdatableVerticalTicker with OrientationBuilder, SizeChangedLayoutNotifier and a ValueKey with this data as the key for UpdatableVerticalTicker.

This is a nice example how to do this.

A demo video of how the ticker can look like, you can find here on my Github page: https://github.com/eventcatcher/updatable_vertical_ticker?tab=readme-ov-file#updatable-vertical-ticker-project

# Feedback

Please feel free to [give me any feedback](https://github.com/eventcatcher/updatable_vertical_ticker/issues) helping support this plugin !