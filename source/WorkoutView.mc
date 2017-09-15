using Toybox.WatchUi as Ui;

class WorkoutView extends Ui.View {

  private var _message;

  function initialize(message) {
    _message = message;
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.WorkoutLayout(dc));
    var message = Ui.loadResource(Rez.Strings.updatedString);
    var view = View.findDrawableById("message");
    message += _message;
    view.setText(message);
  }

}
