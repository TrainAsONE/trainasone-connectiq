using Toybox.Application as Application;
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class Error {

  static function showAbout() {
    var message = Ui.loadResource(Rez.Strings.aboutApp) + AppVersion;
    Ui.switchToView(new ErrorView(message), new ErrorDelegate(), Ui.SLIDE_DOWN);
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
    var menu = new Ui.Menu();
    if (mModel.hasWorkout()) {
      menu.addItem(Ui.loadResource(Rez.Strings.menuShowSaved), :showSaved);
    }
    menu.addItem(Ui.loadResource(Rez.Strings.menuRetry), :refetchWorkout);
    mModel.addStandardMenuOptions(menu);

    Ui.pushView(menu, new WorkoutMenuDelegate(), Ui.SLIDE_UP);
  }

}
