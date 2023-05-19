import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class WorkoutDelegate extends WatchUi.BehaviorDelegate {

  private var mModel;

  function initialize() {
    BehaviorDelegate.initialize();
    mModel = Application.getApp().model;
  }

  function onMenu() as Boolean {
    return showMenu();
  }

  function onSelect() as Boolean {
    return showMenu();
  }

  function showMenu() as Boolean {
    var menu = new WatchUi.Menu();
    if(mModel.hasWorkout()) {
      menu.setTitle(mModel.getName());
    }
    switch (mModel.downloadStatus) {
      case DownloadStatus.OK:
        menu.addItem(WatchUi.loadResource(Rez.Strings.menuStartWorkout), :startWorkout);
        menu.addItem(WatchUi.loadResource(Rez.Strings.stepTarget) + ": " + mModel.mergedStepTarget(), :adjustStepTarget);
        menu.addItem(WatchUi.loadResource(Rez.Strings.stepNames) + ": " + mModel.mergedStepName(), :adjustStepName);
        menu.addItem(WatchUi.loadResource(Rez.Strings.menuIncludeRunBackStep) + ": " + yesNo(mModel.mergedIncludeRunBackStep()), :adjustIncludeRunBackStep);
        break;
      case DownloadStatus.EXTERNAL_SCHEDULE:
      case DownloadStatus.NO_WORKOUT_AVAILABLE:
        menu.addItem(WatchUi.loadResource(Rez.Strings.menuOpenCommitments), :openCommitments);
        break;
      case DownloadStatus.DEVICE_DOES_NOT_SUPPORT_DOWNLOAD:
        menu.addItem(WatchUi.loadResource(Rez.Strings.menuDownloadNotSupported), :noWorkoutDownloadNotSupported);
        break;
      case DownloadStatus.INSUFFICIENT_SUBSCRIPTION_CAPABILITIES:
        menu.addItem(mModel.problemResource(Rez.Strings.menuStartWorkout), :noWorkoutInsufficientSubscriptionCapabilities);
        break;
      case DownloadStatus.WORKOUT_NOT_DOWNLOAD_CAPABLE:
        menu.addItem(mModel.problemResource(Rez.Strings.menuStartWorkout), :noWorkoutNotDownloadCapable);
        break;
      case DownloadStatus.RESPONSE_CODE_ZERO:
        menu.addItem(mModel.problemResource(Rez.Strings.menuStartWorkout), :cannotLoadWorkoutData);
        break;
      case DownloadStatus.RESPONSE_MISSING_WORKOUT_DATA:
        menu.addItem(mModel.problemResource(Rez.Strings.menuStartWorkout), :cannotLoadWorkoutData);
        break;
      case DownloadStatus.DOWNLOAD_TIMEOUT:
        menu.addItem(mModel.problemResource(Rez.Strings.menuStartWorkout), :noWorkoutDownloadTimeout);
        break;
    }

    if (mModel.isAdjustPermitted()) {
      menu.addItem(WatchUi.loadResource(Rez.Strings.adjustTemperature) + ": " + yesNo(mModel.mergedAdjustForTemperature()), :adjustTemperature);
      menu.addItem(WatchUi.loadResource(Rez.Strings.adjustUndulation) + ": " + yesNo(mModel.mergedAdjustForUndulation()), :adjustUndulation);
    }

    menu.addItem(WatchUi.loadResource(Rez.Strings.menuRefetchWorkout), :refetchWorkout);

    mModel.addStandardMenuOptions(menu);
    WatchUi.pushView(menu, new WorkoutMenuDelegate(null), WatchUi.SLIDE_UP);
    return true;
  }

  static function yesNo(val as Boolean) as String {
    return WatchUi.loadResource(val ? Rez.Strings.yes : Rez.Strings.no);
  }

}

class WorkoutMenuDelegate extends WatchUi.MenuInputDelegate {

  private var mModel;
  private var _activeTransaction;
  private var _url;

  function initialize(url as String) {
    MenuInputDelegate.initialize();
    mModel = Application.getApp().model;
    _url = url;
  }

  public function handleDeferredIntent(intent as Intent) {
    _activeTransaction = null;
    System.exitTo(intent);
  }

  function onMenuItem(item) {
    switch(item) {
      case :moreInfo:
        Communications.openWebPage(_url, { "appVersion" => AppVersion, "device" => System.getDeviceSettings().partNumber}, null);
        break;
      case :about:
        Message.showAbout();
        break;
      case :openCommitments:
        Communications.openWebPage(mModel.serverUrl + "/commitments", null, null);
        break;
      case :openWebsite:
        Communications.openWebPage(mModel.serverUrl, null, null);
        break;
      case :startWorkout:
        // Use deferred intent handling workaround from Garmin to avoid issues on 645 firmware (SDK 3.0.3)
        Application.getApp().log("intent: " + (mModel.deferredIntent ? "deferred" : "instant"));
        if (mModel.deferredIntent) {
          _activeTransaction = new self.DeferredIntent(self, mModel.downloadIntent);
          return;
        } else {
          System.exitTo(mModel.downloadIntent);
        }
        break;
      default:
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        break;
    }

    var downloadReason = null; // XXX i18n
    switch (item) {
      case :adjustIncludeRunBackStep:
        downloadReason = "Run back step set to\n" + yesNo(mModel.adjustIncludeRunBackStep());
        break;
      case :adjustStepName:
        downloadReason = "Step name set to\n" + mModel.adjustStepName();
        break;
      case :adjustStepTarget:
        downloadReason = "Step target set to\n" + mModel.adjustStepTarget();
        break;
      case :adjustTemperature:
        downloadReason = "Adjust temperature set to\n" + yesNo(mModel.adjustAdjustForTemperature());
        break;
      case :adjustUndulation:
        downloadReason = "Adjust undulation set to\n" + yesNo(mModel.adjustAdjustForUndulation());
        break;
      case :refetchWorkout:
        downloadReason = "Refetching workout";
        break;
      case :retry:
        downloadReason = "Retrying";
        break;
      case :showSaved:
        WatchUi.switchToView(new WorkoutView(), new WorkoutDelegate(), WatchUi.SLIDE_IMMEDIATE);
        break;
      case :switchServer:
        mModel.switchServer();
        downloadReason = "Switching server to\n" + mModel.serverUrl;
        break;
      case :switchUser:
        WatchUi.switchToView(new GrantView(false, true), new GrantDelegate(), WatchUi.SLIDE_IMMEDIATE);
        break;
      // error cases below
      case :noWorkoutDownloadNotSupported:
        Message.showErrorResourceWithMoreInfo(Rez.Strings.errorDownloadNotSupported, Urls.NOT_DOWNLOAD_NOT_SUPPORTED);
        break;
      case :noWorkoutNotDownloadCapable:
        Message.showErrorResourceWithMoreInfo(Rez.Strings.errorNotDownloadCapable, Urls.NOT_DOWNLOAD_CAPABLE);
        break;
      case :noWorkoutInsufficientSubscriptionCapabilities:
        Message.showErrorResourceWithMoreInfo(Rez.Strings.errorInsufficientSubscriptionCapabilities, Urls.INSUFFICIENT_SUBSCRIPTION_CAPABILITIES);
        break;
      case :noWorkoutDownloadTimeout:
        Message.showErrorResourceWithMoreInfo(Rez.Strings.errorDownloadTimeout, Urls.DOWNLOAD_TIMEOUT);
        break;
      case :cannotLoadWorkoutData:
        Message.showErrorResourceWithMoreInfo(Rez.Strings.errorCannotLoadWorkoutData, Urls.CANNOT_LOAD_WORKOUT_DATA);
        break;
    }

    if (downloadReason != null) {
      WatchUi.switchToView(new DownloadView(downloadReason), new DownloadDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }

  }

  /*
  // We could include this in an error message when workout storage is "full"
  function countDownloadedWorkouts() {
    int count = 0;
    if (Toybox has :PersistedContent) {
      var iterator = PersistedContent.getWorkouts();
      var workout = iterator.next();
      while (workout != null) {
        ++count;
        workout = iterator.next();
      }
    }
    return count;
  }
  */

}
