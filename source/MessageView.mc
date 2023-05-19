import Toybox.System;
import Toybox.WatchUi;

// Show error message
class MessageView extends WatchUi.View {

  private var _message;

  function initialize(message) {
    _message = message;
    Application.getApp().log("message: " + _message);
    View.initialize();
  }

  // Should allow a menu/select to restart main loop
  function onLayout(dc) as Void {
    setLayout(Rez.Layouts.StandardLayout(dc));
    (View.findDrawableById("message") as WatchUi.Text).setText(_message);
  }

}
