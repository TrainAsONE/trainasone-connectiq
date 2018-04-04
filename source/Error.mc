using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.PersistedContent;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class Error {
  static function showErrorMessage(message) {
    Ui.switchToView(new ErrorView(message), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
  }

  static function showErrorResource(rez) {
    showErrorMessage(Ui.loadResource(rez));
  }
}

class ErrorDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    showErrorMenu();
  }

  function onSelect() {
    showErrorMenu();
  }

  function showErrorMenu() {
    var workoutIntent = null;
    var workoutKey = Store.getWorkoutName();
    if (workoutKey != null && Toybox has :PersistedContent) {
      var iterator = PersistedContent.getWorkouts();
      var workout = iterator.next();
      while (workout != null) {
        if (workout.getName().equals(workoutKey)) { // Find the first match by name
          workoutIntent = workout.toIntent();
          break;
        }
        workout = iterator.next();
      }
    }
    var menu = workoutIntent != null ? new Rez.Menus.ErrorMenuWithSaved() : new Rez.Menus.ErrorMenu();
    Ui.pushView(menu, new ErrorMenuDelegate(workoutIntent), Ui.SLIDE_UP);
  }

}

class ErrorMenuDelegate extends Ui.MenuInputDelegate {

  var _workoutIntent;

  function initialize(workoutIntent) {
    MenuInputDelegate.initialize();
    _workoutIntent = workoutIntent;
  }

  function onMenuItem(item) {
    if (item == :about) {
      Error.showErrorMessage(Ui.loadResource(Rez.Strings.aboutApp) + AppVersion);
      return;
    }

    Ui.popView(Ui.SLIDE_IMMEDIATE);
    if (item == :retry) {
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :refetchWorkout) {
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :openWebsite) {
      Comm.openWebPage(ServerUrl, null, null);
    } else if (item == :switchUser) {
      Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :showSaved) {
      Ui.switchToView(new WorkoutView(false), new WorkoutDelegate(_workoutIntent), Ui.SLIDE_IMMEDIATE);
    }
  }

 }
