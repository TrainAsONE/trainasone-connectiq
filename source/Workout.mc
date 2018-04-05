using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

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
    showMenu();
  }

  function showMenu() {
    var menu = new WatchUi.Menu();
    menu.setTitle(Store.getSummary()["name"]);
    var stepTarget = Store.getMergedStepTarget();
    var adjustTemperature = Store.getMergedAdjustTemperature();
    var adjustUndulation = Store.getMergedAdjustUndulation();

    switch (Store.getDownloadResult()) {
      case TaoConstants.DOWNLOAD_RESULT_OK:
        menu.addItem(Ui.loadResource(Rez.Strings.menuStartWorkout), :startWorkout);
        menu.addItem(Ui.loadResource(Rez.Strings.stepTarget) + ": " + stepTarget, :stepTarget);
        break;
      case TaoConstants.DOWNLOAD_RESULT_UNSUPPORTED:
        menu.addItem(Ui.loadResource(Rez.Strings.menuDownloadNotSupported), :downloadNotSupported);
        break;
      case TaoConstants.DOWNLOAD_RESULT_NO_WORKOUT:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoWorkout), :noWorkout);
        break;
      case TaoConstants.DOWNLOAD_RESULT_INSUFFICIENT_SUBSCRIPTION_CAPABILITIES:
        menu.addItem(Ui.loadResource(Rez.Strings.menuInsufficientSubscriptionCapabilities), :insufficientSubscriptionCapabilities);
        break;
      case TaoConstants.DOWNLOAD_RESULT_NO_FIT_DATA_LOADED:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoFitDataLoaded), :noFitDataLoaded);
        break;
    }

    if (Store.getAdjustPermitted()) {
      menu.addItem(Ui.loadResource(Rez.Strings.adjustTemperature) + ": " + yesNo(adjustTemperature), :adjustTemperature);
      menu.addItem(Ui.loadResource(Rez.Strings.adjustUndulation) + ": " + yesNo(adjustUndulation), :adjustUndulation);
    }
    menu.addItem(Ui.loadResource(Rez.Strings.menuRefetchWorkout), :refetchWorkout);
    menu.addItem(Ui.loadResource(Rez.Strings.menuOpenWebsite), :openWebsite);
    menu.addItem(Ui.loadResource(Rez.Strings.menuSwitchUser), :switchUser);
    menu.addItem(Ui.loadResource(Rez.Strings.menuAbout), :about);

    Ui.pushView(menu, new WorkoutMenuDelegate(_workoutIntent), Ui.SLIDE_UP);
  }

  function yesNo(val) {
    return Ui.loadResource(val ? Rez.Strings.yes : Rez.Strings.no);
  }

}

class WorkoutMenuDelegate extends Ui.MenuInputDelegate {

  private var _workoutIntent;

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
    if (item == :startWorkout) {
      Sys.exitTo(_workoutIntent);
    } else if (item == :refetchWorkout) {
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :stepTarget) {
      var stepTarget = Store.getMergedStepTarget();
      if (stepTarget.equals("SPEED")) {
        stepTarget = "HEART_RATE";
      } else if (stepTarget.equals("HEART_RATE")) {
        stepTarget = "HEART_RATE_RECOVERY";
      } else if (stepTarget.equals("HEART_RATE_RECOVERY")) {
        stepTarget = "SPEED";
      }
      if (Store.getDisplayPreferencesStepTarget().equals(stepTarget)) {
        stepTarget = null; // Reset to null if it matches current server choice
      }
      Store.setStepTarget(stepTarget);
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :adjustTemperature) {
      Store.setAdjustTemperature(!Store.getMergedAdjustTemperature());
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :adjustUndulation) {
      Store.setAdjustUndulation(!Store.getMergedAdjustUndulation());
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :openWebsite) {
      Comm.openWebPage(ServerUrl, null, null);
    } else if (item == :switchUser) {
      Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :downloadNotSupported) {
      Error.showErrorResource(Rez.Strings.errorDownloadNotSupported);
    } else if (item == :insufficientSubscriptionCapabilities) {
      Error.showErrorResource(Rez.Strings.errorInsufficientSubscriptionCapabilities);
    } else if (item == :noWorkout) {
      Error.showErrorResource(Rez.Strings.errorNoWorkoutSteps);
    } else if (item == :noFitDataLoaded) {
      Error.showErrorResource(Rez.Strings.errorNoFitDataLoaded);
    }
  }

}
