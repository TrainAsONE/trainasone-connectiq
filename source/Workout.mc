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
    if (_workoutIntent != null) {
      Sys.exitTo(_workoutIntent);
    } else {
      showMenu();
    }
  }

  function showMenu() {
    var menu = new WatchUi.Menu();
    var summary = App.getApp().getProperty(TaoConstants.OBJ_SUMMARY);
    menu.setTitle(summary["name"]);
    switch (App.getApp().getProperty(TaoConstants.OBJ_DOWNLOAD_RESULT)) {
      case TaoConstants.DOWNLOAD_RESULT_OK:
        menu.addItem(Ui.loadResource(Rez.Strings.menuStartWorkout), :startWorkout);
        break;
      case TaoConstants.DOWNLOAD_RESULT_UNSUPPORTED:
        menu.addItem(Ui.loadResource(Rez.Strings.menuDownloadNotSupported), :downloadNotSupported);
        break;
      case TaoConstants.DOWNLOAD_RESULT_NO_WORKOUT_STEPS:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoWorkoutSteps), :noWorkoutSteps);
        break;
      case TaoConstants.DOWNLOAD_RESULT_INSUFFICIENT_SUBSCRIPTION_CAPABILITIES:
        menu.addItem(Ui.loadResource(Rez.Strings.menuInsufficientSubscriptionCapabilities), :insufficientSubscriptionCapabilities);
        break;
      case TaoConstants.DOWNLOAD_RESULT_NO_FIT_DATA_LOADED:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoFitDataLoaded), :noFitDataLoaded);
        break;
    }
    menu.addItem(Ui.loadResource(Rez.Strings.menuRefetchWorkout), :refetchWorkout);
    menu.addItem(Ui.loadResource(Rez.Strings.menuOpenWebsite), :openWebsite);
    menu.addItem(Ui.loadResource(Rez.Strings.menuSwitchUser), :switchUser);
    menu.addItem(Ui.loadResource(Rez.Strings.menuAbout), :about);

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
    } else if (item == :openWebsite) {
      Comm.openWebPage(ServerUrl, null, null);
    } else if (item == :switchUser) {
      Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :downloadNotSupported) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.errorDownloadNotSupported)), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :insufficientSubscriptionCapabilities) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.errorInsufficientSubscriptionCapabilities)), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :noWorkoutSteps) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.errorNoWorkoutSteps)), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :noFitDataLoaded) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.errorNoFitDataLoaded)), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :about) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.aboutApp) + AppVersion), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
