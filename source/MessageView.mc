using Toybox.WatchUi as Ui;
using Toybox.System;

// Show error message
class MessageView extends Ui.View {

  private var _message;

  function initialize(message) {
    _message = message;
    Application.getApp().log("message: " + _message);
    View.initialize();
  }

  // Should allow a menu/select to restart main loop
  function onLayout(dc) {
    setLayout(Rez.Layouts.StandardLayout(dc));
    View.findDrawableById("message").setText(_message);
  }

}
