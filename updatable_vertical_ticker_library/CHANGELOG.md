## 1.0.1
\- update license to MIT


## 1.0.0

\- Initial release of **Updatable Vertical Ticker**

\- Vertical text scrolling (bottom → center → top)

\- Configurable scroll duration, hold duration and cycle pause

\- Sequential scrolling of multiple text entries

\- Dynamic text list updates without interrupting the current cycle

\- Internal state machine driven by a single `Ticker`

\- Rendering via `CustomPainter` for flicker-free animations

\- No use of `AnimationController`, `Timer` or async delays



\### Performance

\- Constant memory usage

\- No layout rebuilds during animation

\- Optimized for dashboards, signage and long-running displays