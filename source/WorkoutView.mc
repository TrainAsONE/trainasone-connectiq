using Toybox.Application as App;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi as Ui;

class WorkoutView extends Ui.View {

  function initialize() {
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.StandardLayout(dc));
    // Graphics.Dc.getHeight() fails with "Could not find symbol mHeight", presumably as we have not displayed yet
    var deviceSettings = System.getDeviceSettings();
    var height = deviceSettings.screenHeight;
    var width = deviceSettings.screenWidth;
    var centre = width / 2;
    // System.println("display: " + width + "x" + height);
    var view = View.findDrawableById("message");

    // Not a good way to handle this this.
    // On the other hand the odds on Garmin releasing new devices with low resolution
    // screens where width is an odd numbers of pixels...
    view.setLocation(centre, height <= 148 ? 62 : 74); // vivoactive
    view.setFont(width == 215 ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL);

    var workoutFormatter = new WorkoutFormatter();
    view.setText(workoutFormatter.buildMessageFromWorkout());
  }

}
