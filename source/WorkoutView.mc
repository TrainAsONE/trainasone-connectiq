using Toybox.WatchUi as Ui;

class WorkoutView extends Ui.View {

  private var _message;
  private var _updated;

  function initialize(message, updated) {
    _message = message;
    _updated = updated;
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.WorkoutLayout(dc));
    var message = Ui.loadResource(Rez.Strings.nextWorkoutString);
    var view = View.findDrawableById("message");
    var note = _updated ? Ui.loadResource(Rez.Strings.updatedString) : Ui.loadResource(Rez.Strings.noChangeString);
    message += _message + note;
    view.setText(message);
  }

}
