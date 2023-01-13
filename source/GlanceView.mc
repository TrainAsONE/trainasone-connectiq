using Toybox.WatchUi;
using Toybox.Graphics as Gfx;

(:glance)
class GlanceView extends WatchUi.GlanceView {

  var _workoutText;

  function initialize() {
    GlanceView.initialize();
  }

  function onLayout(dc) as Void {
    // FIXME - adjust formatting to merge lines 2 & 3 for glance view
    _workoutText = WorkoutFormatter.buildMessageFromWorkout(Application.getApp().model);
    // Application.getApp().log("workoutText(" + _workoutText + ")");
  }

  function onUpdate(dc) as Void {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    dc.drawText(0, 0, Graphics.FONT_XTINY, _workoutText, Graphics.TEXT_JUSTIFY_LEFT);
  }

}