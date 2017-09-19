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
    var message = Ui.loadResource(Rez.Strings.errorString);
    var view = View.findDrawableById("message");
    message += _message;
    view.setText(message);
  }

}
