import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

class WorkoutView extends WatchUi.View {
  function initialize() {
    View.initialize();
  }

  function onLayout(dc as Graphics.Dc) as Void {
    setLayout(Rez.Layouts.StandardLayout(dc));
    // Graphics.Dc.getHeight() fails with "Could not find symbol mHeight", presumably as we have not displayed yet
    var deviceSettings = System.getDeviceSettings();
    var height = deviceSettings.screenHeight;
    var width = deviceSettings.screenWidth;
    var centre = width / 2;
    // Application.getApp().log("display: " + width + "x" + height);
    var view = View.findDrawableById("message") as WatchUi.Text;

    // Start text higher on vivoactive's shorter screen
    view.setLocation(centre, height <= 148 ? 62 : 74); // vivoactive

    // MEDIUM font works better on devices with 215 wide screens (235, 630, 735xt, etc)
    // as the SMALL font is much harder to read
    view.setFont(width == 215 ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL);

    var workoutFormatter = new WorkoutFormatter();
    view.setText(
      workoutFormatter.buildMessageFromWorkout()
    );
  }
}
