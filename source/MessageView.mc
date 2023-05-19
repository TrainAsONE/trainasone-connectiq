import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Show error message
class MessageView extends WatchUi.View {
  private var _message as String;

  function initialize(message as String) {
    _message = message;
    Application.getApp().log("message: " + _message);
    View.initialize();
  }

  // Should allow a menu/select to restart main loop
  function onLayout(dc as Graphics.Dc) as Void {
    setLayout(Rez.Layouts.StandardLayout(dc));
    (View.findDrawableById("message") as WatchUi.Text).setText(_message);
  }
}
