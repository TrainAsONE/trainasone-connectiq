using Toybox.Application as Application;
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class Error {

  static function showAbout() {
    showMessage(Ui.loadResource(Rez.Strings.aboutApp) + AppVersion);
  }

  static function showMessage(message) {
    Ui.switchToView(new ErrorView(message), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
  }

  static function showErrorMessage(message) {
    var mModel = Application.getApp().model;
    var fullMessage = message + "\n" + (mModel.downloadIntent ? Ui.loadResource(Rez.Strings.pressForSavedWorkout) : Ui.loadResource(Rez.Strings.pressForOptions));
    showMessage(fullMessage);
  }

  static function showErrorResource(rez) {
    showErrorMessage(Ui.loadResource(rez));
  }
}

class ErrorDelegate extends Ui.BehaviorDelegate {

  private var mModel;

  function initialize() {
    BehaviorDelegate.initialize();
    mModel = Application.getApp().model;
  }

  function onMenu() {
    showErrorMenu();
  }

  function onSelect() {
    showErrorMenu();
  }

  function showErrorMenu() {
    var menu = new WatchUi.Menu();
    if (mModel.hasWorkout()) {
      menu.addItem(Ui.loadResource(Rez.Strings.menuShowSaved), :showSaved);
    }
    menu.addItem(Ui.loadResource(Rez.Strings.menuRetry), :refetchWorkout);
    mModel.addStandardMenuOptions(menu);

    Ui.pushView(menu, new ErrorMenuDelegate(), Ui.SLIDE_UP);
  }

}

class ErrorMenuDelegate extends Ui.MenuInputDelegate {

  private var mModel;

  function initialize() {
    MenuInputDelegate.initialize();
    mModel = Application.getApp().model;
  }

  function onMenuItem(item) {

    switch(item) {
      case :about:
        Error.showAbout();
        break;
      default:
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        break;
    }

    switch(item) {
      case :retry:
        Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case :refetchWorkout:
        Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case :switchServer:
        mModel.switchServer();
        Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case :openWebsite:
        Comm.openWebPage(mModel.serverUrl, null, null);
        break;
      case :switchUser:
        Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case :showSaved:
        Ui.switchToView(new WorkoutView(), new WorkoutDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
    }

  }

 }
