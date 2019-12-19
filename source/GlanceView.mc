using Toybox.WatchUi;
using Toybox.Graphics as Gfx;

(:glance)
class GlanceView extends WatchUi.GlanceView {

  var _workoutText;

  function initialize() {
    GlanceView.initialize();
  }

  function onLayout(dc) {
    var workoutFormatter = new WorkoutFormatter();
    // FIXME - adjust formatting to merge lines 2 & 3 for glance view
    _workoutText = workoutFormatter.buildMessageFromWorkout();
    // System.println("workoutText(" + _workoutText + ")");
  }

  function onUpdate(dc) {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.drawText(0, 0, Graphics.FONT_XTINY, _workoutText, Graphics.TEXT_JUSTIFY_LEFT);
  }

}