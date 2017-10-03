using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class WorkoutDelegate extends Ui.BehaviorDelegate {

  private var _workoutIntent;

  function initialize(workoutIntent) {
    BehaviorDelegate.initialize();
    _workoutIntent = workoutIntent;
  }

  function onMenu() {
    showMenu();
  }

  function onSelect() {
    if (_workoutIntent != null) {
      Sys.exitTo(_workoutIntent);
    } else {
      showMenu();
    }
  }

  function showMenu() {
    var menu = _workoutIntent != null ? new Rez.Menus.WorkoutMenu() : new Rez.Menus.WorkoutMenuNoIntent();
    Ui.pushView(menu, new WorkoutMenuDelegate(_workoutIntent), Ui.SLIDE_UP);
  }

}

class WorkoutMenuDelegate extends Ui.MenuInputDelegate {

  private var _workoutIntent;

  function initialize(workoutIntent) {
    MenuInputDelegate.initialize();
    _workoutIntent = workoutIntent;
  }

  function onMenuItem(item) {
    if (item == :startWorkout) {
      Sys.exitTo(_workoutIntent);
    } else if (item == :refetchWorkout) {
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :switchUser) {
      Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :downloadNotSuported) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.downloadNotSupported)), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :about) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.aboutApp) + AppVersion), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
