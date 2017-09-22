using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

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
    Ui.pushView(new Rez.Menus.ErrorMenu(), new ErrorMenuDelegate(), Ui.SLIDE_UP);
  }

}

class ErrorMenuDelegate extends Ui.MenuInputDelegate {

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :retry) {
      Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :switchUser) {
      Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (item == :about) {
      Ui.switchToView(new ErrorView(Ui.loadResource(Rez.Strings.aboutApp) + AppVersion), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
