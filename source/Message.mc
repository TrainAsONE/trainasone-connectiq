using Toybox.Application as Application;
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class Message {

  static function showAbout() {
    var message = Ui.loadResource(Rez.Strings.aboutApp) + AppVersion;
    showMessage(message, Urls.ABOUT_URL);
  }

  static function showErrorResource(rez) {
    showErrorResourceWithMoreInfo(rez, null);
  }

  static function showErrorResourceWithMoreInfo(rez, url) {
    showErrorMessageWithMoreInfo(Ui.loadResource(rez), url);
  }

  static function showErrorMessage(message) {
    showErrorMessageWithMoreInfo(message, null);
  }

  static function showErrorMessageWithMoreInfo(message, url) {
    var mModel = Application.getApp().model;
    var fullMessage = message + "\n"
        + Ui.loadResource(mModel.downloadIntent ? Rez.Strings.pressForSavedWorkout : Rez.Strings.pressForOptions);
    showMessage(fullMessage, url);
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
