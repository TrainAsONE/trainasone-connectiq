using Toybox.Application as App;
using Toybox.PersistedContent;
using Toybox.System;
using Toybox.WatchUi as Ui;

const STORE_ACCESS_TOKEN = "accessToken";
const STORE_SUMMARY = "summary";
const STORE_DOWNLOAD_NAME = "workoutName";
const STORE_DOWNLOAD_STATUS = "downloadResult";
const STORE_SERVER_URL = "serverUrl";

const STORE_STEP_TARGET = "stepTarget";
const STORE_STEP_NAME = "stepName";
const STORE_ADJUST_TEMPERATURE = "adjustTemperature";
const STORE_ADJUST_UNDULATION = "adjustUndulation";
const STORE_INCLUDE_RUN_BACK_STEP = "includeRunBackStep";

const PREF_WORKOUT_STEP_NAME = "workoutStepName";
const PREF_WORKOUT_STEP_TARGET = "workoutStepTarget";
const PREF_ADJUST_FOR_TEMPERATURE = "adjustForTemperature";
const PREF_ADJUST_FOR_UNDULATION ="adjustForUndulation";
const PREF_INCLUDE_RUN_BACK_STEP = "includeRunBackStep";

class TaoModel {

  var accessToken;     // Access token returned by TrainAsONE Oauth2, used in later API calls
  var downloadStatus;  // Download result status
  var updated = false; // Has the workout changed since our last stored version
  var downloadIntent;  // Stored intent, used to start workout
  var downloadName;    // Name for workout stored under PersistedContent
  var workoutSummary;  // All details of workout and related data from server
  var message;         // Alternate message to show (not yet used)
  var localPref = {};  // Locally overridden localPref
  var serverUrl;       // Current server URL

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
    if (accessToken == null) { // compat: Fallback to property used by 0.0.17 or earlier
      accessToken = App.getApp().getProperty(STORE_ACCESS_TOKEN);
    }
    workoutSummary = App.getApp().getProperty(STORE_SUMMARY);
    downloadName = App.getApp().getProperty(STORE_DOWNLOAD_NAME);
    downloadStatus = App.getApp().getProperty(STORE_DOWNLOAD_STATUS);
    if (downloadStatus == null) {
      downloadStatus = DownloadStatus.NOT_YET_ATTEMPTED;
    }
    downloadIntent = determineDownloadIntentFromPersistedContent();

    // compat: Load then clear any data from 0.23 or earlier
    loadPref(PREF_WORKOUT_STEP_TARGET, STORE_STEP_TARGET);
    loadPref(PREF_WORKOUT_STEP_TARGET, STORE_STEP_TARGET);
    loadPref(PREF_WORKOUT_STEP_NAME, STORE_STEP_NAME);
    loadPref(PREF_ADJUST_FOR_TEMPERATURE, STORE_ADJUST_TEMPERATURE);
    loadPref(PREF_ADJUST_FOR_UNDULATION, STORE_ADJUST_UNDULATION);
    loadPref(PREF_INCLUDE_RUN_BACK_STEP, STORE_INCLUDE_RUN_BACK_STEP);
    // System.println("start: " + serverUrl + " " + accessToken);
  }

  // compat: Load then clear any data from 0.23 or earlier
  function loadPref(prefName, storeName) {
    var value = App.getApp().getProperty(storeName);
    if (value != null) {
      localPref[prefName] = value;
      App.getApp().setProperty(storeName, null);
    }
  }

  function showMessage(thisMessage) {
    System.println("showMessage: " + thisMessage);
    message = thisMessage;
  }

  function showResource(resource) {
    showMessage(Ui.loadResource(resource));
  }

  function setDownloadStatus(updatedDownloadStatus) {
    downloadStatus = updatedDownloadStatus;
    App.getApp().setProperty(STORE_DOWNLOAD_STATUS, downloadStatus);
  }

  function adjustStepTarget() {
    var stepTarget = mergedStepTarget();
    if (stepTarget.equals("SPEED")) {
      stepTarget = "HEART_RATE_RECOVERY";
    } else if (stepTarget.equals("HEART_RATE_RECOVERY")) {
      stepTarget = "HEART_RATE_SLOW";
    } else if (stepTarget.equals("HEART_RATE_SLOW")) {
      stepTarget = "HEART_RATE";
    } else if (stepTarget.equals("HEART_RATE")) {
      stepTarget = "SPEED";
    }
    localPref[PREF_WORKOUT_STEP_TARGET] = stepTarget;
    return stepTarget;
  }

  function adjustStepName() {
    var stepName = mergedStepName();
    if (stepName.equals("STEP_NAME")) {
      stepName = "BLANK";
    } else if (stepName.equals("BLANK")) {
      stepName = "PACE_RANGE";
    } else if (stepName.equals("PACE_RANGE")) {
      stepName = "STEP_NAME";
    }
    localPref[PREF_WORKOUT_STEP_NAME] = stepName;
    return stepName;
  }

  function adjustAdjustForTemperature() {
    return adjustBooleanPreference(PREF_ADJUST_FOR_TEMPERATURE);
  }

  function adjustAdjustForUndulation() {
    return adjustBooleanPreference(PREF_ADJUST_FOR_UNDULATION);
  }

  function adjustIncludeRunBackStep() {
    return adjustBooleanPreference(PREF_INCLUDE_RUN_BACK_STEP);
  }

  function adjustBooleanPreference(prefName) {
    var newVal = !mergedPreference(prefName);
    localPref[prefName] = newVal;
    return newVal;
  }

  function setDownload(download) {
    // System.println("setDownload: " + download.getName());
    setDownloadStatus(DownloadStatus.OK);
    downloadIntent = download.toIntent();
    downloadName = download.getName();
    App.getApp().setProperty(STORE_DOWNLOAD_NAME, downloadName);
  }

  function updateWorkoutSummary(updatedWorkoutSummary) {
    var oldName = lookupWorkoutSummary("name") == null ? "" : lookupWorkoutSummary("name");
    var newName = updatedWorkoutSummary["name"] == null ? "" : updatedWorkoutSummary["name"];
    workoutSummary = updatedWorkoutSummary;
    updated = newName.equals(oldName); // XXX base on other changes too
    // System.println("workoutSummary: " + workoutSummary);
    localPref = {};
    App.getApp().setProperty(STORE_SUMMARY, workoutSummary);
  }

  function setAccessToken(updatedAccessToken) {
    accessToken = updatedAccessToken;
    App.getApp().setProperty(STORE_ACCESS_TOKEN + "-" + serverUrl, accessToken);
  }

  function getDisplayPreferences() {
    return lookupWorkoutSummary("displayPreferences");
  }

  function getMessage() {
    return lookupWorkoutSummary("message");
  }

  function mergedStepTarget() {
    return mergedPreference(PREF_WORKOUT_STEP_TARGET);
  }

  function mergedStepName() {
    return mergedPreference(PREF_WORKOUT_STEP_NAME);
  }

  function mergedAdjustForTemperature() {
    return mergedPreference(PREF_ADJUST_FOR_TEMPERATURE);
  }

  function mergedAdjustForUndulation() {
    return mergedPreference(PREF_ADJUST_FOR_UNDULATION);
  }

  function mergedIncludeRunBackStep() {
    return mergedPreference(PREF_INCLUDE_RUN_BACK_STEP);
  }

  function mergedPreference(prefName) {
    return localPref[prefName] == null ? lookupDisplayPreferences(prefName) : prefName;
  }

  // For now key off the downloadPermitted setting
  function isAdjustPermitted() {
    return isDownloadPermitted();
  }

  function isDownloadCapable() {
    return lookupWorkoutSummaryBoolean("downloadCapable");
  }

  function isDownloadPermitted() {
    return lookupWorkoutSummaryBoolean("downloadPermitted");
  }

  function isExternalSchedule() {
    return lookupWorkoutSummaryBoolean("externalSchedule");
  }

  function isSupport() {
    return lookupWorkoutSummaryBoolean("support");
  }

  function hasWorkout() {
    return lookupWorkoutSummary("name") != null;
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

  // Helpers to lookup values safely in the presence of null workoutSummary/displayPreferences
  function lookupDisplayPreferences(key) {
    var displayPreferences = getDisplayPreferences();
    return displayPreferences == null ? null : displayPreferences[key];
  }

  function lookupWorkoutSummary(key) {
    return workoutSummary == null ? null : workoutSummary[key];
  }

  function lookupWorkoutSummaryBoolean(key) {
    return workoutSummary == null ? false : workoutSummary[key];
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