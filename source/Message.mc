import Toybox.Application;
import Toybox.Communications;
import Toybox.WatchUi;

class Message {

  static function showAbout() {
    var message = WatchUi.loadResource(Rez.Strings.aboutApp) + AppVersion;
    showMessage(message, Urls.ABOUT_URL);
  }

  static function showErrorResource(rez) {
    showErrorResourceWithMoreInfo(rez, null);
  }

  static function showErrorResourceWithMoreInfo(rez, url) {
    showErrorMessageWithMoreInfo(WatchUi.loadResource(rez), url);
  }

  static function showErrorMessage(message) {
    showErrorMessageWithMoreInfo(message, null);
  }

  static function showErrorMessageWithMoreInfo(message, url) {
    var mModel = Application.getApp().model;
    var fullMessage = message + "\n"
        + WatchUi.loadResource(mModel.downloadIntent ? Rez.Strings.pressForSavedWorkout : Rez.Strings.pressForOptions);
    showMessage(fullMessage, url);
  }

  static function showMessage(message, url) {
    WatchUi.switchToView(new MessageView(message), new MessageDelegate(url), WatchUi.SLIDE_IMMEDIATE);
  }

}

class MessageDelegate extends WatchUi.BehaviorDelegate {

  private var mModel;
  private var _url;

  function initialize(url) {
    BehaviorDelegate.initialize();
    mModel = Application.getApp().model;
    _url = url;
  }

  function onMenu() {
    return showErrorMenu();
  }

  function onSelect() {
    return showErrorMenu();
  }

  function showErrorMenu() {
    var menu = new WatchUi.Menu();
    if (_url != null) {
      menu.addItem(WatchUi.loadResource(Rez.Strings.moreInfo), :moreInfo);
    }
    if (mModel.hasWorkout()) {
      menu.addItem(WatchUi.loadResource(Rez.Strings.menuShowSaved), :showSaved);
    }
    menu.addItem(WatchUi.loadResource(Rez.Strings.menuRetry), :refetchWorkout);
    mModel.addStandardMenuOptions(menu);

    WatchUi.pushView(menu, new WorkoutMenuDelegate(_url), WatchUi.SLIDE_UP);
    return true;
  }

}
