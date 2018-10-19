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
      menu.setTitle(mModel.workoutSummary["name"]);
    }
    var stepTarget = mModel.mergedStepTarget();
    var stepName = mModel.mergedStepName();
    var adjustTemperature = mModel.mergedAdjustTemperature();
    var adjustUndulation = mModel.mergedAdjustUndulation();
    var includeRunBackStep = mModel.mergedIncludeRunBackStep();

    switch (mModel.downloadStatus) {
      case DownloadStatus.OK:
        menu.addItem(Ui.loadResource(Rez.Strings.menuStartWorkout), :startWorkout);
        menu.addItem(Ui.loadResource(Rez.Strings.stepTarget) + ": " + stepTarget, :adjustStepTarget);
        menu.addItem(Ui.loadResource(Rez.Strings.stepNames) + ": " + stepName, :adjustStepName);
        menu.addItem(Ui.loadResource(Rez.Strings.menuIncludeRunBackStep) + ": " + yesNo(includeRunBackStep), :adjustIncludeRunBackStep);
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
      menu.addItem(Ui.loadResource(Rez.Strings.adjustTemperature) + ": " + yesNo(adjustTemperature), :adjustTemperature);
      menu.addItem(Ui.loadResource(Rez.Strings.adjustUndulation) + ": " + yesNo(adjustUndulation), :adjustUndulation);
    }

    menu.addItem(Ui.loadResource(Rez.Strings.menuRefetchWorkout), :refetchWorkout);

    mModel.addStandardMenuOptions(menu);
    Ui.pushView(menu, new WorkoutMenuDelegate(), Ui.SLIDE_UP);
  }

  function yesNo(val) {
    return Ui.loadResource(val ? Rez.Strings.yes : Rez.Strings.no);
  }

}

class WorkoutMenuDelegate extends Ui.MenuInputDelegate {

  private var mModel;
  private var _activeTransaction;

  function initialize() {
    MenuInputDelegate.initialize();
    mModel = Application.getApp().model;
  }

  public function handleDeferredIntent( intent ) {
    _activeTransaction = null;
    System.exitTo(intent);
  }

  function onMenuItem(item) {
    switch(item) {
      case :about:
        Error.showAbout();
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
        mModel.setIncludeRunBackStep(!mModel.mergedIncludeRunBackStep());
        downloadReason = "Run back step set to\n" + yesNo(mModel.mergedIncludeRunBackStep());
        break;
      case :adjustStepName:
        var stepName = mModel.mergedStepName();
        if (stepName.equals("STEP_NAME")) {
          stepName = "BLANK";
        } else if (stepName.equals("BLANK")) {
          stepName = "PACE_RANGE";
        } else if (stepName.equals("PACE_RANGE")) {
          stepName = "STEP_NAME";
        }
        mModel.setStepName(stepName);
        downloadReason = "Step name set to\n" + stepName;
        break;
      case :adjustStepTarget:
        var stepTarget = mModel.mergedStepTarget();
        if (stepTarget.equals("SPEED")) {
          stepTarget = "HEART_RATE_RECOVERY";
        } else if (stepTarget.equals("HEART_RATE_RECOVERY")) {
          stepTarget = "HEART_RATE_SLOW";
        } else if (stepTarget.equals("HEART_RATE_SLOW")) {
          stepTarget = "HEART_RATE";
        } else if (stepTarget.equals("HEART_RATE")) {
          stepTarget = "SPEED";
        }
        mModel.setStepTarget(stepTarget);
        downloadReason = "Step target set to\n" + stepTarget;
        break;
      case :adjustTemperature:
        mModel.setAdjustTemperature(!mModel.mergedAdjustTemperature());
        downloadReason = "Adjust temperature set to\n" + yesNo(mModel.mergedAdjustTemperature());
        break;
      case :adjustUndulation:
        mModel.setAdjustUndulation(!mModel.mergedAdjustUndulation());
        downloadReason = "Adjust undulation set to\n" + yesNo(mModel.mergedAdjustUndulation());
        break;
      case :openCommitments:
        Comm.openWebPage(mModel.serverUrl + "/commitments", null, null);
        break;
      case :openWebsite:
        Comm.openWebPage(mModel.serverUrl, null, null);
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
        Error.showErrorResource(Rez.Strings.errorDownloadNotSupported);
        break;
      case :noWorkoutNotDownloadCapable:
        Error.showErrorResource(Rez.Strings.errorNotDownloadCapable);
        break;
      case :noWorkoutInsufficientSubscriptionCapabilities:
        Error.showErrorResource(Rez.Strings.errorInsufficientSubscriptionCapabilities);
        break;
      case :cannotLoadWorkoutData:
        Error.showErrorResource(Rez.Strings.errorCannotLoadWorkoutData);
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
