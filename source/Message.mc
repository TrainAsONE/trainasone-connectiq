using Toybox.Application as Application;
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class Message {

  static function showAbout() {
    var message = Ui.loadResource(Rez.Strings.aboutApp) + AppVersion;
    showMessage(message, Urls.ABOUT_URL);
  }

  static function showErrorMessage(message) {
    showErrorResourceWithMoreInfo(message, null);
  }

  static function showErrorResourceWithMoreInfo(message, url) {
    var mModel = Application.getApp().model;
    var fullMessage = message + "\n" + (mModel.downloadIntent ? Ui.loadResource(Rez.Strings.pressForSavedWorkout) : Ui.loadResource(Rez.Strings.pressForOptions));
    showMessage(fullMessage, null);
  }

  static function showErrorResource(rez) {
    showErrorMessage(Ui.loadResource(rez));
  }

  static function showMessage(message, url) {
    Ui.switchToView(new MessageView(message), new MessageDelegate(url), Ui.SLIDE_IMMEDIATE);
  }

}

class MessageDelegate extends Ui.BehaviorDelegate {

  private var mModel;
  private var _url;

  function initialize(url) {
    BehaviorDelegate.initialize();
    mModel = Application.getApp().model;
    _url = url;
  }

  function onMenu() {
    showErrorMenu();
  }

  function onSelect() {
    showErrorMenu();
  }

  function showErrorMenu() {
    var menu = new Ui.Menu();
    if (_url != null) {
      menu.addItem(Ui.loadResource(Rez.Strings.moreInfo), :moreInfo);
    }
    if (mModel.hasWorkout()) {
      menu.addItem(Ui.loadResource(Rez.Strings.menuShowSaved), :showSaved);
    }
    menu.addItem(Ui.loadResource(Rez.Strings.menuRetry), :refetchWorkout);
    mModel.addStandardMenuOptions(menu);

    Ui.pushView(menu, new WorkoutMenuDelegate(_url), Ui.SLIDE_UP);
  }

}
