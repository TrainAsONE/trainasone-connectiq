import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;

class Message {
  static function showAbout() as Void {
    var message = WatchUi.loadResource(Rez.Strings.aboutApp) + AppVersion;
    showMessage(message, Urls.ABOUT_URL);
  }

  static function showErrorResource(rez as Symbol) as Void {
    showErrorResourceWithUrl(rez, null);
  }

  static function showErrorResourceWithUrl(
    rez as Symbol,
    url as String?
  ) as Void {
    showErrorMessageWithUrl(WatchUi.loadResource(rez) as String, url);
  }

  static function showErrorMessage(message as String) as Void {
    showErrorMessageWithUrl(message, null);
  }

  static function showErrorMessageWithUrl(
    message as String,
    url as String?
  ) as Void {
    var mModel = Application.getApp().model;
    var fullMessage =
      message +
      "\n" +
      WatchUi.loadResource(
        mModel.downloadIntent
          ? Rez.Strings.pressForSavedWorkout
          : Rez.Strings.pressForOptions
      );
    showMessage(fullMessage, url);
  }

  static function showMessage(message as String, url as String?) as Void {
    WatchUi.switchToView(
      new MessageView(message),
      new MessageDelegate(url),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}

class MessageDelegate extends WatchUi.BehaviorDelegate {
  private var mModel as TaoModel;
  private var _url as String?;

  function initialize(url as String?) {
    BehaviorDelegate.initialize();
    mModel = Application.getApp().model;
    _url = url;
  }

  function onMenu() as Boolean {
    return showErrorMenu();
  }

  function onSelect() as Boolean {
    return showErrorMenu();
  }

  function showErrorMenu() as Boolean {
    var menu = new WatchUi.Menu();
    if (_url != null) {
      menu.addItem(loadStringResource(Rez.Strings.moreInfo), :moreInfo);
    }
    if (mModel.hasWorkout()) {
      menu.addItem(loadStringResource(Rez.Strings.menuShowSaved), :showSaved);
    }
    menu.addItem(loadStringResource(Rez.Strings.menuRetry), :refetchWorkout);
    mModel.addStandardMenuOptions(menu);

    WatchUi.pushView(menu, new WorkoutMenuDelegate(_url), WatchUi.SLIDE_UP);
    return true;
  }

  function loadStringResource(rez as Symbol) as String {
    return WatchUi.loadResource(rez) as String;
  }
}
