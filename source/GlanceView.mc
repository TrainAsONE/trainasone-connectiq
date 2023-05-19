import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class GlanceView extends WatchUi.GlanceView {
  var _workoutText as String?;

  function initialize() {
    GlanceView.initialize();
  }

  function onLayout(dc as Graphics.Dc) as Void {
    // FIXME - adjust formatting to merge lines 2 & 3 for glance view
    _workoutText = WorkoutFormatter.buildMessageFromWorkout(
      Application.getApp().model
    );
    // Application.getApp().log("workoutText(" + _workoutText + ")");
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    if (_workoutText != null) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      dc.drawText(
        0,
        0,
        Graphics.FONT_XTINY,
        _workoutText as String,
        Graphics.TEXT_JUSTIFY_LEFT
      );
    }
  }
}
