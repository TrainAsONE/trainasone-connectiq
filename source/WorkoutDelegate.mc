using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.System;
using Toybox.WatchUi as Ui;

class WorkoutDelegate extends Ui.BehaviorDelegate {

  private var mModel;

  function initialize() {
    BehaviorDelegate.initialize();
    mModel = Application.getApp().model;
  }

  function onMenu() {
    showMenu();
  }

  function onSelect() {
    showMenu();
  }

  function showMenu() {
    var menu = new Ui.Menu();
    if(mModel.hasWorkout()) {
      menu.setTitle(mModel.getName());
    }
    switch (mModel.downloadStatus) {
      case DownloadStatus.OK:
        menu.addItem(Ui.loadResource(Rez.Strings.menuStartWorkout), :startWorkout);
        menu.addItem(Ui.loadResource(Rez.Strings.stepTarget) + ": " + mModel.mergedStepTarget(), :adjustStepTarget);
        menu.addItem(Ui.loadResource(Rez.Strings.stepNames) + ": " + mModel.mergedStepName(), :adjustStepName);
        menu.addItem(Ui.loadResource(Rez.Strings.menuIncludeRunBackStep) + ": " + yesNo(mModel.mergedIncludeRunBackStep()), :adjustIncludeRunBackStep);
        break;
      case DownloadStatus.EXTERNAL_SCHEDULE:
      case DownloadStatus.NO_WORKOUT_AVAILABLE:
        menu.addItem(Ui.loadResource(Rez.Strings.menuOpenCommitments), :openCommitments);
        break;
      case DownloadStatus.DEVICE_DOES_NOT_SUPPORT_DOWNLOAD:
        menu.addItem(Ui.loadResource(Rez.Strings.menuDownloadNotSupported), :noWorkoutDownloadNotSupported);
        break;
      case DownloadStatus.INSUFFICIENT_SUBSCRIPTION_CAPABILITIES:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoStartWorkout), :noWorkoutInsufficientSubscriptionCapabilities);
        break;
      case DownloadStatus.WORKOUT_NOT_DOWNLOAD_CAPABLE:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoStartWorkout), :noWorkoutNotDownloadCapable);
        break;
      case DownloadStatus.RESPONSE_CODE_ZERO:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoWorkout0), :cannotLoadWorkoutData);
        break;
      case DownloadStatus.RESPONSE_MISSING_WORKOUT_DATA:
        menu.addItem(Ui.loadResource(Rez.Strings.menuNoWorkout), :cannotLoadWorkoutData);
        break;
    }

    if (mModel.isAdjustPermitted()) {
      menu.addItem(Ui.loadResource(Rez.Strings.adjustTemperature) + ": " + yesNo(mModel.mergedAdjustForTemperature()), :adjustTemperature);
      menu.addItem(Ui.loadResource(Rez.Strings.adjustUndulation) + ": " + yesNo(mModel.mergedAdjustForUndulation()), :adjustUndulation);
    }

    menu.addItem(Ui.loadResource(Rez.Strings.menuRefetchWorkout), :refetchWorkout);

    mModel.addStandardMenuOptions(menu);
    Ui.pushView(menu, new WorkoutMenuDelegate(null), Ui.SLIDE_UP);
  }

  function yesNo(val) {
    return Ui.loadResource(val ? Rez.Strings.yes : Rez.Strings.no);
  }

}

class WorkoutMenuDelegate extends Ui.MenuInputDelegate {

  private var mModel;
  private var _activeTransaction;
  private var _url;

  function initialize(url) {
    MenuInputDelegate.initialize();
    mModel = Application.getApp().model;
    _url = url;
  }

  public function handleDeferredIntent( intent ) {
    _activeTransaction = null;
    System.exitTo(intent);
  }

  function onMenuItem(item) {
    switch(item) {
      case :moreInfo:
        Comm.openWebPage(_url, { "appVersion" => AppVersion, "device" => System.getDeviceSettings().partNumber}, null);
        break;
      case :about:
        Message.showAbout();
        break;
      case :openCommitments:
        Comm.openWebPage(mModel.serverUrl + "/commitments", null, null);
        break;
      case :openWebsite:
        Comm.openWebPage(mModel.serverUrl, null, null);
        break;
      case :startWorkout:
        // Use deferred intent handling workaround from Garmin to avoid issues on 645 firmware (SDK 3.0.3)
        // System.exitTo(mModel.downloadIntent);
        _activeTransaction = new self.DeferredIntent(self, mModel.downloadIntent);
        break;
      default:
        Ui.popView(Ui.SLIDE_IMMEDIATE);
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
        Ui.switchToView(new WorkoutView(), new WorkoutDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case :switchServer:
        mModel.switchServer();
        downloadReason = "Switching server to\n" + mModel.serverUrl;
        break;
      case :switchUser:
        Ui.switchToView(new GrantView(false, true), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
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
      case :cannotLoadWorkoutData:
        Message.showErrorResourceWithMoreInfo(Rez.Strings.errorCannotLoadWorkoutData, Urls.CANNOT_LOAD_WORKOUT_DATA);
        break;
    }

    if (downloadReason != null) {
      Ui.switchToView(new DownloadView(downloadReason), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
    }

  }

  function yesNo(val) {
    return Ui.loadResource(val ? Rez.Strings.yes : Rez.Strings.no);
  }


}
