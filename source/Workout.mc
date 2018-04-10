using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.System;
using Toybox.WatchUi as Ui;

class WorkoutDelegate extends Ui.BehaviorDelegate {

  private var mModel;

  function initialize() {
    BehaviorDelegate.initialize();
    mModel = Application.getApp().model;
  }

  function onMenu() {
    showMenu();
  }

  function onSelect() {
    showMenu();
  }

  function showMenu() {
    var menu = new WatchUi.Menu();
    menu.setTitle(mModel.workoutSummary["name"]);
    var stepTarget = mModel.mergedStepTarget();
    var adjustTemperature = mModel.mergedAdjustTemperature();
    var adjustUndulation = mModel.mergedAdjustUndulation();

    switch (mModel.downloadResult) {
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

    if (mModel.isAdjustPermitted()) {
      menu.addItem(Ui.loadResource(Rez.Strings.adjustTemperature) + ": " + yesNo(adjustTemperature), :adjustTemperature);
      menu.addItem(Ui.loadResource(Rez.Strings.adjustUndulation) + ": " + yesNo(adjustUndulation), :adjustUndulation);
    }
    menu.addItem(Ui.loadResource(Rez.Strings.menuRefetchWorkout), :refetchWorkout);
    menu.addItem(Ui.loadResource(Rez.Strings.menuOpenWebsite), :openWebsite);
    menu.addItem(Ui.loadResource(Rez.Strings.menuSwitchUser), :switchUser);
    menu.addItem(Ui.loadResource(Rez.Strings.menuAbout), :about);

    Ui.pushView(menu, new WorkoutMenuDelegate(), Ui.SLIDE_UP);
  }

  function yesNo(val) {
    return Ui.loadResource(val ? Rez.Strings.yes : Rez.Strings.no);
  }

}

class WorkoutMenuDelegate extends Ui.MenuInputDelegate {

  private var mModel;

  function initialize() {
    MenuInputDelegate.initialize();
    mModel = Application.getApp().model;
  }

  function onMenuItem(item) {
    if (item == :about) {
      Error.showErrorMessage(Ui.loadResource(Rez.Strings.aboutApp) + AppVersion);
      return;
    } else if (item == :startWorkout) {
      System.exitTo(mModel.downloadIntent); // If we popView() before this it breaks on devices but not the simulator
      return;
    }

    Ui.popView(Ui.SLIDE_IMMEDIATE);
    if (item == :refetchWorkout) {
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :stepTarget) {
      var stepTarget = mModel.mergedStepTarget();
      if (stepTarget.equals("SPEED")) {
        stepTarget = "HEART_RATE";
      } else if (stepTarget.equals("HEART_RATE")) {
        stepTarget = "HEART_RATE_RECOVERY";
      } else if (stepTarget.equals("HEART_RATE_RECOVERY")) {
        stepTarget = "SPEED";
      }
      if (mModel.getDisplayPreferencesStepTarget().equals(stepTarget)) {
        stepTarget = null; // Reset to null if it matches current server choice
      }
      mModel.setStepTarget(stepTarget);
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :adjustTemperature) {
      mModel.setAdjustTemperature(!mModel.mergedAdjustTemperature());
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :adjustUndulation) {
      mModel.setAdjustUndulation(!mModel.mergedAdjustUndulation());
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
