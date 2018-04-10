using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.PersistedContent;
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
    var menu = mModel.downloadIntent != null ? new Rez.Menus.ErrorMenuWithSaved() : new Rez.Menus.ErrorMenu();
    Ui.pushView(menu, new ErrorMenuDelegate(), Ui.SLIDE_UP);
  }

}

class ErrorMenuDelegate extends Ui.MenuInputDelegate {

  function initialize() {
    MenuInputDelegate.initialize();
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
      Ui.switchToView(new WorkoutView(), new WorkoutDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

 }
