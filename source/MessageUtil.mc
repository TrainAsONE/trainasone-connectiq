import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;

/// All of these should be static, but Application.getApp().model does not work in
/// a static method with Type Checking enabled
class MessageUtil {
  public static function fullErrorMessage(message as String) as String {
    var mModel = Application.getApp().model;
    return (
      message +
      "\n" +
      WatchUi.loadResource(
        mModel.downloadIntent != null
          ? Rez.Strings.pressForSavedWorkout
          : Rez.Strings.pressForOptions
      )
    );
  }

  public static function showAbout() as Void {
    var message =
      WatchUi.loadResource(Rez.Strings.aboutApp) +
      Application.getApp().appVersion();
    showMessage(message, Urls.ABOUT_URL);
  }

  public static function showErrorResource(rez as ResourceId) as Void {
    showErrorResourceWithUrl(rez, null);
  }

  public static function showErrorResourceWithUrl(rez as ResourceId, url as String?) as Void {
    showErrorMessageWithUrl(WatchUi.loadResource(rez) as String, url);
  }

  public static function showErrorMessage(message as String) as Void {
    showErrorMessageWithUrl(message, null);
  }

  public static function showErrorMessageWithUrl(message as String, url as String?) as Void {
    showMessage(fullErrorMessage(message), url);
  }

  public static function showMessage(message as String, url as String?) as Void {
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
    menu.addItem(
      loadStringResource(Rez.Strings.menuRetry),
      mModel.accessToken == null ? :switchUser : :refetchWorkout
    );
    mModel.addStandardMenuOptions(menu);

    WatchUi.pushView(menu, new WorkoutMenuDelegate(_url), WatchUi.SLIDE_UP);
    return true;
  }

  function loadStringResource(rez as ResourceId) as String {
    return WatchUi.loadResource(rez) as String;
  }
}
