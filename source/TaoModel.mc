using Toybox.Application as App;
using Toybox.System;
using Toybox.WatchUi as Ui;

const STORE_ACCESS_TOKEN = "accessToken";
const STORE_SUMMARY = "summary";
const STORE_DOWNLOAD_NAME = "workoutName";
const STORE_DOWNLOAD_STATUS = "downloadResult";
const STORE_STEP_TARGET = "stepTarget";
const STORE_STEP_NAME = "stepName";
const STORE_ADJUST_TEMPERATURE = "adjustTemperature";
const STORE_ADJUST_UNDULATION = "adjustUndulation";
const STORE_INCLUDE_RUN_BACK_STEP = "includeRunBackStep";
const STORE_SERVER_URL = "serverUrl";

class TaoModel {

  var accessToken;  // Access token returned by TrainAsONE Oauth2, used in later API calls

  var downloadStatus; // Download result status

  var updated;    // Has the workout changed since our last stored version

  var downloadIntent; // Stored intent, used to start workout

  var downloadName; // Name for workout stored under PersistedContent

  var workoutSummary; // All details of workout and related data from server

  var message;    // Alternate message to show (not yet used)

  var stepTargetPref; // User preference for step target, can be null

  var stepNamePref; // User preference for step name, can be null

  var adjustTemperaturePref;  // User preference for adjust temperature, can be null

  var adjustUndulationPref; // User preference for adjust temperature, can be null

  var includeRunBackStepPref; // User preference for including run back, can be null

  var serverUrl; // Current server URL

  function determineDownloadIntentFromPersistedContent() {
    if (downloadName != null && Toybox has :PersistedContent) {
      var iterator = PersistedContent.getWorkouts();
      var workout = iterator.next();
      while (workout != null) {
        if (workout.getName().equals(downloadName)) { // Find the first match by name
          return workout.toIntent();
          break;
        }
        workout = iterator.next();
      }
    }
    return null;
  }

  function initialize() {
    serverUrl = App.getApp().getProperty(STORE_SERVER_URL);
    updateServerUrl(0);
    accessToken = App.getApp().getProperty(STORE_ACCESS_TOKEN + "-" + serverUrl);
    if (accessToken == null) { // Backwards compat for 0.0.17 and earlier
      accessToken = App.getApp().getProperty(STORE_ACCESS_TOKEN);
    }
    workoutSummary = App.getApp().getProperty(STORE_SUMMARY);
    downloadName = App.getApp().getProperty(STORE_DOWNLOAD_NAME);
    downloadStatus = App.getApp().getProperty(STORE_DOWNLOAD_STATUS);
    stepTargetPref = App.getApp().getProperty(STORE_STEP_TARGET);
    stepNamePref = App.getApp().getProperty(STORE_STEP_NAME);
    adjustTemperaturePref = App.getApp().getProperty(STORE_ADJUST_TEMPERATURE);
    adjustUndulationPref = App.getApp().getProperty(STORE_ADJUST_UNDULATION);
    includeRunBackStepPref = App.getApp().getProperty(STORE_INCLUDE_RUN_BACK_STEP);
    downloadIntent = determineDownloadIntentFromPersistedContent();
    System.println("start: " + serverUrl + " " + accessToken);
  }

  function showMessage(thisMessage) {
    System.println("showMessage: " + thisMessage);
    message = thisMessage;
  }

  function showResource(resource) {
    showMessage(Ui.loadResource(resource));
  }

  function showWorkout() {
    System.println("showWorkout");
    message = null;
  }

  function setDownloadStatus(updatedDownloadStatus) {
    downloadStatus = updatedDownloadStatus;
    App.getApp().setProperty(STORE_DOWNLOAD_STATUS, downloadStatus);
  }

  function setStepTarget(updatedStepTargetPref) {
    if (getDisplayPreferencesStepTarget().equals(updatedStepTargetPref)) {
      stepTargetPref = null; // Reset to null if it matches current server choice
    } else {
      stepTargetPref = updatedStepTargetPref;
    }
    App.getApp().setProperty(STORE_STEP_TARGET, stepTargetPref);
  }

  function setStepName(updatedStepNamePref) {
    if (getDisplayPreferencesStepName().equals(updatedStepNamePref)) {
      stepNamePref = null; // Reset to null if it matches current server choice
    } else {
      stepNamePref = updatedStepNamePref;
    }
    App.getApp().setProperty(STORE_STEP_NAME, stepNamePref);
  }

  function setAdjustTemperature(updatedAdjustTemperaturePref) {
    adjustTemperaturePref = updatedAdjustTemperaturePref;
    App.getApp().setProperty(STORE_ADJUST_TEMPERATURE, adjustTemperaturePref);
  }

  function setAdjustUndulation(updatedAdjustUndulationPref) {
    adjustUndulationPref = updatedAdjustUndulationPref;
    App.getApp().setProperty(STORE_ADJUST_UNDULATION, adjustUndulationPref);
  }

  function setIncludeRunBackStep(updatedIncludeRunBackStepPref) {
    includeRunBackStepPref = updatedIncludeRunBackStepPref;
    App.getApp().setProperty(STORE_INCLUDE_RUN_BACK_STEP, includeRunBackStepPref);
  }

  function setDownload(download) {
    System.println("setDownload: " + download.getName());
    setDownloadStatus(DownloadStatus.OK);
    downloadIntent = download.toIntent();
    downloadName = download.getName();
    App.getApp().setProperty(STORE_DOWNLOAD_NAME, downloadName);
  }

  function updateWorkoutSummary(updatedWorkoutSummary) {
    var oldName = workoutSummary == null || workoutSummary["name"] == null ? "" : workoutSummary["name"];
    var newName = updatedWorkoutSummary["name"] == null ? "" : updatedWorkoutSummary["name"];
    workoutSummary = updatedWorkoutSummary;
    updated = newName.equals(oldName);
    App.getApp().setProperty(STORE_SUMMARY, workoutSummary);
  }

  function setAccessToken(updatedAccessToken) {
    accessToken = updatedAccessToken;
    App.getApp().setProperty(STORE_ACCESS_TOKEN + "-" + serverUrl, accessToken);
  }

  function getDisplayPreferences() {
    return workoutSummary == null ? null : workoutSummary["displayPreferences"];
  }

  function getDisplayPreferencesStepTarget() {
    return getDisplayPreferences()["workoutStepTarget"];
  }

  function mergedStepTarget() {
    return stepTargetPref == null ? getDisplayPreferencesStepTarget() : stepTargetPref;
  }

    function getDisplayPreferencesStepName() {
    return getDisplayPreferences()["workoutStepName"];
  }

  function mergedStepName() {
    return stepNamePref == null ? getDisplayPreferencesStepName() : stepNamePref;
  }

  function mergedAdjustTemperature() {
    return adjustTemperaturePref == null ? getDisplayPreferences()["eapTemperature"] : adjustTemperaturePref;
  }

  function mergedAdjustUndulation() {
    return adjustUndulationPref == null ? getDisplayPreferences()["eapUndulation"] : adjustUndulationPref;
  }

  function mergedIncludeRunBackStep() {
    return includeRunBackStepPref == null ? getDisplayPreferences()["includeRunBackStep"] : includeRunBackStepPref;
  }

  // For now key off the downloadPermitted setting
  function isAdjustPermitted() {
    return isDownloadPermitted();
  }

  function isDownloadCapable() {
    return workoutSummary == null ? false : workoutSummary["downloadCapable"];
  }

  function isDownloadPermitted() {
    return workoutSummary == null ? false : workoutSummary["downloadPermitted"];
  }

  function isExternalSchedule() {
    return workoutSummary == null ? false : workoutSummary["externalSchedule"];
  }

  function isSupport() {
    return workoutSummary == null ? false : workoutSummary["support"];
  }

  function hasWorkout() {
    return workoutSummary != null && workoutSummary["name"] != null;
  }

  function determineDownloadStatus() {
    if (isExternalSchedule()) {
      return DownloadStatus.EXTERNAL_SCHEDULE;
    }
    if (!hasWorkout()) {
      return DownloadStatus.NO_WORKOUT_AVAILABLE;
    }
    if (!(Toybox has :PersistedContent)) {
      return DownloadStatus.DEVICE_DOES_NOT_SUPPORT_DOWNLOAD;
    }
    if (!isDownloadPermitted()) {
      return DownloadStatus.INSUFFICIENT_SUBSCRIPTION_CAPABILITIES;
    }
    if (!isDownloadCapable()) {
      return DownloadStatus.WORKOUT_NOT_DOWNLOAD_CAPABLE;
    }
    return DownloadStatus.OK;
  }

  // XXX Should be moved out to controller class
  function addStandardMenuOptions(menu) {
    menu.addItem(Ui.loadResource(Rez.Strings.menuOpenWebsite), :openWebsite);
    menu.addItem(Ui.loadResource(Rez.Strings.menuSwitchUser), :switchUser);
    menu.addItem(Ui.loadResource(Rez.Strings.menuAbout), :about);
    if (isSupport()) {
      menu.addItem(Ui.loadResource(Rez.Strings.server) + ": " + serverUrl, :switchServer);
    }
  }

  // Lookup current serverUrl in $.ServerUrls, and if found apply offset, wrapped at start/end
  function updateServerUrl(offset) {
    var i = 0;
    if (serverUrl != null) {
      for (; i < $.ServerUrls.size(); ++i) {
        if (serverUrl.equals($.ServerUrls[i])) {
          break;
        }
      }
    }
    if (i >= $.ServerUrls.size()) { // serverUrl not found in $.ServerUrls
      i = 0;
    }
    i = i + offset;
    if (i >= $.ServerUrls.size()) { // new index past end of $.ServerUrls
      i = 0;
    } else  if (i < 0) { // new index below start of $.ServerUrls
      i = $.ServerUrls.size() - 1;
    }

    serverUrl = $.ServerUrls[i];
  }

  function switchServer() {
    updateServerUrl(1);
    App.getApp().setProperty(STORE_SERVER_URL, serverUrl);
    accessToken = App.getApp().getProperty(STORE_ACCESS_TOKEN + "-" + serverUrl);
  }
}