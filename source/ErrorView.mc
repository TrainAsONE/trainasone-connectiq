using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// Show error message
class ErrorView extends Ui.View {

  private var _message;

  function initialize(message) {
    _message = message;
    Sys.println("errorMessage: " + _message);
    View.initialize();
  }

  // Should allow a menu/select to restart main loop
  function onLayout(dc) {
    setLayout(Rez.Layouts.ErrorLayout(dc));
    var view = View.findDrawableById("message");
    view.setText(_message);
  }

}
