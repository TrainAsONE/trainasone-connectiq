using Toybox.Application as App;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi as Ui;

class WorkoutView extends Ui.View {

  function initialize() {
    View.initialize();
  }

  function onLayout(dc) as Void {
    setLayout(Rez.Layouts.StandardLayout(dc));
    // Graphics.Dc.getHeight() fails with "Could not find symbol mHeight", presumably as we have not displayed yet
    var deviceSettings = System.getDeviceSettings();
    var height = deviceSettings.screenHeight;
    var width = deviceSettings.screenWidth;
    var centre = width / 2;
    // Application.getApp().log("display: " + width + "x" + height);
    var view = View.findDrawableById("message");

    // Start text higher on vivoactive's shorter screen
    view.setLocation(centre, height <= 148 ? 62 : 74); // vivoactive

    // MEDIUM font works better on devices with 215 wide screens (235, 630, 735xt, etc)
    // as the SMALL font is much harder to read
    view.setFont(width == 215 ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL);

    view.setText(WorkoutFormatter.buildMessageFromWorkout(Application.getApp().model));
  }

}
