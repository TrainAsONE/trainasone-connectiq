using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class WorkoutDelegate extends Ui.BehaviorDelegate {

  private var _intent;

  function initialize(intent) {
    BehaviorDelegate.initialize();
    _intent = intent;
  }

  function onMenu() {
    Ui.pushView(new Rez.Menus.WorkoutMenu(), new WorkoutMenuDelegate(_intent), Ui.SLIDE_UP);
  }

  function onSelect() {
    Sys.exitTo(_intent);
  }

}

class WorkoutMenuDelegate extends Ui.MenuInputDelegate {

  private var _intent;

  function initialize(intent) {
    MenuInputDelegate.initialize();
    _intent = intent;
  }

  function onMenuItem(item) {
    if (item == :startWorkout) {
      Sys.exitTo(_intent);
    } else if (item == :refetchWorkout) {
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :switchUser) {
      Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}