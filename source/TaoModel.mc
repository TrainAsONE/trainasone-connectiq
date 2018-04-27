using Toybox.Application as App;
using Toybox.System;

const STORE_ACCESS_TOKEN = "accessToken";
const STORE_SUMMARY = "summary";
const STORE_DOWNLOAD_NAME = "workoutName";
const STORE_DOWNLOAD_RESULT = "downloadResult";
const STORE_STEP_TARGET = "stepTarget";
const STORE_ADJUST_TEMPERATURE = "adjustTemperature";
const STORE_ADJUST_UNDULATION = "adjustUndulation";

class TaoModel {

  var accessToken;  // Access token returned by TrainAsONE Oauth2, used in later API calls

  var downloadResult; // Download result status

  var updated;    // Has the workout changed since our last stored version

  var downloadIntent; // Stored intent, used to start workout

  var downloadName; // Name for workout stored under PersistedContent

  var workoutSummary; // All details of workout and related data from server

  var message;    // Alternate message to show (not yet used)

  var stepTargetPref; // User preference for step target, can be null

  var adjustTemperaturePref;  // User preference for adjust temperature, can be null

  var adjustUndulationPref; // User preference for adjust temperature, can be null

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
    accessToken = App.getApp().getProperty(STORE_ACCESS_TOKEN);
    workoutSummary = App.getApp().getProperty(STORE_SUMMARY);
    downloadName = App.getApp().getProperty(STORE_DOWNLOAD_NAME);
    downloadResult = App.getApp().getProperty(STORE_DOWNLOAD_RESULT);
    stepTargetPref = App.getApp().getProperty(STORE_STEP_TARGET);
    adjustTemperaturePref = App.getApp().getProperty(STORE_ADJUST_TEMPERATURE);
    adjustUndulationPref = App.getApp().getProperty(STORE_ADJUST_UNDULATION);
    downloadIntent = determineDownloadIntentFromPersistedContent();
  }

  function showMessage(thisMessage) {
    System.println("showMessage" + thisMessage);
    message = thisMessage;
  }

  function showResource(resource) {
    showMessage(Ui.loadResource(resource));
  }

  function showWorkout() {
    System.println("showWorkout");
    message = null;
  }

  function setDownloadResult(updatedDownloadResult) {
    downloadResult = updatedDownloadResult;
    App.getApp().setProperty(STORE_DOWNLOAD_RESULT, downloadResult);
  }

  function setStepTarget(updatedStepTargetPref) {
    stepTargetPref = updatedStepTargetPref;
    App.getApp().setProperty(STORE_STEP_TARGET, stepTargetPref);
  }

  function setAdjustTemperature(updatedAdjustTemperaturePref) {
    adjustTemperaturePref = updatedAdjustTemperaturePref;
    App.getApp().setProperty(STORE_ADJUST_TEMPERATURE, adjustTemperaturePref);
  }

  function setAdjustUndulation(updatedAdjustUndulationPref) {
    adjustUndulationPref = updatedAdjustUndulationPref;
    App.getApp().setProperty(STORE_ADJUST_UNDULATION, adjustUndulationPref);
  }

  function setDownload(download) {
    System.println("setDownload: " + download.getName());
    setDownloadResult(TaoConstants.DOWNLOAD_RESULT_OK);
    downloadIntent = download.toIntent();
    downloadName = download.getName();
    App.getApp().setProperty(STORE_DOWNLOAD_NAME, downloadName);
  }

  function updateWorkoutSummary(updatedWorkoutSummary) {
    var oldName = workoutSummary["name"] == null ? "" : workoutSummary["name"];
    var newName = updatedWorkoutSummary["name"] == null ? "" : updatedWorkoutSummary["name"];
    workoutSummary = updatedWorkoutSummary;
    updated = newName.equals(oldName);
    App.getApp().setProperty(STORE_SUMMARY, workoutSummary);
  }

  function setAccessToken(updatedAccessToken) {
    accessToken = updatedAccessToken;
    App.getApp().setProperty(STORE_ACCESS_TOKEN, accessToken);
  }

  function getDisplayPreferences() {
    return workoutSummary == null ? null : workoutSummary["displayPreferences"];
  }

  function getDisplayPreferencesStepTarget() {
    return getDisplayPreferences()["stepTarget"];
  }

  function mergedStepTarget() {
    return stepTargetPref == null ? getDisplayPreferences()["stepTarget"] : stepTargetPref;
  }

  function mergedAdjustTemperature() {
    return adjustTemperaturePref == null ? getDisplayPreferences()["eapTemperature"] : adjustTemperaturePref;
  }

  function mergedAdjustUndulation() {
    return adjustUndulationPref == null ? getDisplayPreferences()["eapUndulation"] : adjustUndulationPref;
  }

  // For now key off the downloadPermitted setting
  function isAdjustPermitted() {
    return isDownloadPermitted();
  }

  function isDownloadPermitted() {
    return workoutSummary == null ? false : workoutSummary["downloadPermitted"];
  }

  function isExternalSchedule() {
    return workoutSummary == null ? false : workoutSummary["externalSchedule"];
  }

  function hasWorkout() {
    return workoutSummary["name"] != null;
  }

  function downloadCheck() {
    if (isExternalSchedule()) {
      return TaoConstants.DOWNLOAD_RESULT_EXTERNAL_SCHEDULE;
    }
    if (workoutSummary == null || !hasWorkout()) {
      return TaoConstants.DOWNLOAD_RESULT_NO_WORKOUT_AVAILABLE;
    }
    if (!(Toybox has :PersistedContent)) {
      return TaoConstants.DOWNLOAD_RESULT_UNSUPPORTED;
    }
    if (!isDownloadPermitted()) {
      return TaoConstants.DOWNLOAD_RESULT_INSUFFICIENT_SUBSCRIPTION_CAPABILITIES;
    }
    return null;
  }

}
