import Toybox.Application;
import Toybox.PersistedContent;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

(:glance)
class TaoModel {
  const STORE_ACCESS_TOKEN = "accessToken";
  const STORE_SUMMARY = "summary";
  const STORE_MESSAGE = "message";
  const STORE_DOWNLOAD_NAME = "workoutName";
  const STORE_DOWNLOAD_STATUS = "downloadResult";
  const STORE_SERVER_URL = "serverUrl";

  const PREF_WORKOUT_STEP_NAME = "workoutStepName";
  const PREF_WORKOUT_STEP_TARGET = "workoutStepTarget";
  const PREF_ADJUST_FOR_TEMPERATURE = "adjustForTemperature";
  const PREF_ADJUST_FOR_UNDULATION = "adjustForUndulation";
  const PREF_INCLUDE_RUN_BACK_STEP = "includeRunBackStep";
  const PREF_DEFERRED_INTENT = "deferredIntent";

  const SUMMARY_NAME = "name";
  const SUMMARY_DISPLAY_PREFERENCES = "displayPreferences";
  const SUMMARY_MESSAGE = "message";
  const SUMMARY_DOWNLOAD_CAPABLE = "downloadCapable";
  const SUMMARY_DOWNLOAD_PERMITTED = "downloadPermitted";
  const SUMMARY_EXTERNAL_SCHEDULE = "externalSchedule";
  const SUMMARY_SUPPORT = "support";

  const STEP_NAME_OPTIONS =
    ["STEP_NAME", "BLANK", "PACE_RANGE"] as Array<String>;
  const STEP_TARGET_OPTIONS =
    ["SPEED", "HEART_RATE_RECOVERY", "HEART_RATE_SLOW", "HEART_RATE"] as
    Array<String>;

  typedef Prefs as Dictionary<
    String,
    Boolean or
      Number or
      Double or
      String or
      Dictionary<String, Boolean or Number or Double or String>
  >;

  var accessToken as String?; // Access token returned by TrainAsONE Oauth2, used in later API calls
  var downloadStatus as Number = DownloadStatus.NOT_YET_ATTEMPTED; // Download result status
  var updated as Boolean = false; // Has the workout changed since our last stored version
  var downloadIntent as Intent?; // Stored intent, used to start workout
  var downloadName as String?; // Name for workout stored under PersistedContent
  var workoutSummary as Prefs?; // All details of workout and related data from server
  var workoutMessage as String?; // Alternate message to show (not yet used)
  var localPref as Prefs = {} as Prefs; // Locally overridden preferences
  var serverUrl as String; // Current server URL

  function determineDownloadIntentFromPersistedContent() as Intent? {
    var foundWorkout = null;
    if (downloadName != null && Toybox has :PersistedContent) {
      var perAppWorkouts = PersistedContent has :getAppWorkouts;
      if (!perAppWorkouts) {
        Application.getApp().log(
          "Device does not support removing own workouts"
        );
      }
      var iterator = perAppWorkouts
        ? PersistedContent.getAppWorkouts()
        : PersistedContent.getWorkouts();
      var workout = iterator.next();
      while (workout != null) {
        var hasName = workout has :getName;
        if (
          foundWorkout == null &&
          hasName &&
          workout.getName().equals(downloadName)
        ) {
          // Find the first match by name
          foundWorkout = workout.toIntent();
        } else if (perAppWorkouts) {
          if (workout has :remove) {
            Application.getApp().log(
              "remove previous workout: " + workout.getName()
            );
            workout.remove();
          } else {
            Application.getApp().log(
              "ignore strange non-removable workout: " +
                (hasName ? workout.getName() : "UNKNOWN")
            );
          }
        }
        workout = iterator.next();
      }
    }
    return foundWorkout;
  }

  function initialize() {
    // Will reset to first entry is null, or not in current list
    serverUrl = findInList(
      loadStringProperty(STORE_SERVER_URL),
      $.ServerUrls,
      0
    );
    accessToken = loadStringProperty(STORE_ACCESS_TOKEN + "-" + serverUrl);
    if (accessToken == null) {
      // compat: Fallback to property used by 0.0.17 or earlier
      accessToken = loadStringProperty(STORE_ACCESS_TOKEN);
    }
    workoutSummary = loadProperty(STORE_SUMMARY);
    workoutMessage = loadStringProperty(STORE_MESSAGE);
    downloadName = loadStringProperty(STORE_DOWNLOAD_NAME);
    downloadStatus = loadProperty(STORE_DOWNLOAD_STATUS) as Number?;
    if (downloadStatus == null) {
      downloadStatus = DownloadStatus.NOT_YET_ATTEMPTED;
    }
    downloadIntent = determineDownloadIntentFromPersistedContent();
    // Application.getApp().log("start: " + serverUrl + " " + accessToken);
  }

  function loadStringProperty(propertyName as String) as String? {
    return loadProperty(propertyName) as String?;
  }

  function loadProperty(propertyName as String) as Prefs or Number or Null {
    return (
      Application.getApp().getProperty(propertyName) as Prefs or Number or Null
    );
  }

  function saveProperty(
    propertyName as String,
    propertyValue as Prefs or String or Number or Null
  ) as Void {
    Application.getApp().setProperty(propertyName, propertyValue);
  }

  function problemResource(rez as Symbol) as String {
    // Cannot embed non ascii in literal strings, hence badLeft & badRight
    return (
      "" +
      WatchUi.loadResource(Rez.Strings.badLeft) +
      WatchUi.loadResource(rez) +
      WatchUi.loadResource(Rez.Strings.badRight)
    );
  }

  function setWorkoutMessageResource(rez as Symbol) as Void {
    workoutMessage = problemResource(rez);
  }

  function setDownloadStatus(updatedDownloadStatus as Number) as Void {
    downloadStatus = updatedDownloadStatus;
    saveProperty(STORE_DOWNLOAD_STATUS, downloadStatus);
  }

  function adjustStepTarget() as String {
    var stepTarget = findInList(mergedStepTarget(), STEP_TARGET_OPTIONS, 1);
    localPref[PREF_WORKOUT_STEP_TARGET] = stepTarget;
    return stepTarget;
  }

  function adjustStepName() as String {
    var stepName = findInList(mergedStepName(), STEP_NAME_OPTIONS, 1);
    localPref[PREF_WORKOUT_STEP_NAME] = stepName;
    return stepName;
  }

  function adjustAdjustForTemperature() as Boolean {
    return adjustBooleanPreference(PREF_ADJUST_FOR_TEMPERATURE);
  }

  function adjustAdjustForUndulation() as Boolean {
    return adjustBooleanPreference(PREF_ADJUST_FOR_UNDULATION);
  }

  function adjustIncludeRunBackStep() as Boolean {
    return adjustBooleanPreference(PREF_INCLUDE_RUN_BACK_STEP);
  }

  function adjustBooleanPreference(prefName as String) as Boolean {
    var newVal = !(mergedPreference(prefName) as Boolean);
    localPref[prefName] = newVal;
    return newVal;
  }

  function updateDownload(download as Workout) as Void {
    Application.getApp().log("updateDownload: " + download.getName());
    setDownloadStatus(DownloadStatus.OK);
    downloadIntent = download.toIntent();
    downloadName = download.getName();
    determineDownloadIntentFromPersistedContent(); // Will clean out other workouts
    saveProperty(STORE_DOWNLOAD_NAME, downloadName);
  }

  function updateWorkoutSummary(updatedWorkoutSummary as Prefs) as Void {
    var oldName = getName() == null ? "" : getName();
    var newName =
      updatedWorkoutSummary[SUMMARY_NAME] == null
        ? ""
        : updatedWorkoutSummary[SUMMARY_NAME];
    workoutSummary = updatedWorkoutSummary;
    updated = !newName.equals(oldName); // XXX base on other changes too
    // Application.getApp().log("workoutSummary: " + workoutSummary);
    localPref = {} as Prefs;
    workoutMessage = null;
    saveProperty(STORE_SUMMARY, workoutSummary);
  }

  function setAccessToken(updatedAccessToken as String?) as Void {
    accessToken = updatedAccessToken;
    saveProperty(STORE_ACCESS_TOKEN + "-" + serverUrl, accessToken);
  }

  function getDisplayPreferences() as Prefs? {
    return lookupWorkoutSummary(SUMMARY_DISPLAY_PREFERENCES);
  }

  function getMessage() as String? {
    return workoutMessage == null
      ? lookupWorkoutSummary(SUMMARY_MESSAGE) as String
      : workoutMessage;
  }

  function getName() as String? {
    return lookupWorkoutSummary(SUMMARY_NAME) as String;
  }

  function mergedStepTarget() as String {
    return mergedPreference(PREF_WORKOUT_STEP_TARGET) as String;
  }

  function mergedStepName() as String {
    return mergedPreference(PREF_WORKOUT_STEP_NAME) as String;
  }

  function mergedAdjustForTemperature() as Boolean {
    return mergedPreference(PREF_ADJUST_FOR_TEMPERATURE) as Boolean;
  }

  function mergedAdjustForUndulation() as Boolean {
    return mergedPreference(PREF_ADJUST_FOR_UNDULATION) as Boolean;
  }

  function mergedIncludeRunBackStep() as Boolean {
    return mergedPreference(PREF_INCLUDE_RUN_BACK_STEP) as Boolean;
  }

  function mergedDeferredIntent() as Boolean {
    return mergedPreference(PREF_DEFERRED_INTENT) as Boolean;
  }

  function mergedPreference(prefName as String) {
    return localPref[prefName] == null
      ? lookupDisplayPreference(prefName)
      : prefName;
  }

  // For now key off the downloadPermitted setting
  function isAdjustPermitted() as Boolean {
    return isDownloadPermitted();
  }

  function isDownloadCapable() as Boolean {
    return lookupWorkoutSummaryBoolean(SUMMARY_DOWNLOAD_CAPABLE);
  }

  function isDownloadPermitted() as Boolean {
    return lookupWorkoutSummaryBoolean(SUMMARY_DOWNLOAD_PERMITTED);
  }

  function isExternalSchedule() as Boolean {
    return lookupWorkoutSummaryBoolean(SUMMARY_EXTERNAL_SCHEDULE);
  }

  function isSupport() as Boolean {
    return lookupWorkoutSummaryBoolean(SUMMARY_SUPPORT);
  }

  function hasWorkout() as Boolean {
    return getName() != null;
  }

  function determineDownloadStatus() as Number {
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
  function lookupDisplayPreference(
    key as String
  ) as String or Number or Boolean {
    var displayPreferences = getDisplayPreferences();
    return displayPreferences == null ? null : displayPreferences[key];
  }

  function lookupWorkoutSummary(
    key as String
  ) as String or Number or Double or Prefs or Null {
    return workoutSummary == null ? null : workoutSummary[key];
  }

  function lookupWorkoutSummaryBoolean(key as String) as Boolean {
    return workoutSummary == null ? false : workoutSummary[key];
  }

  // XXX Should be moved out to controller class
  function addStandardMenuOptions(menu as Menu) as Void {
    menu.addItem(
      WatchUi.loadResource(Rez.Strings.menuOpenWebsite),
      :openWebsite
    );
    menu.addItem(WatchUi.loadResource(Rez.Strings.menuSwitchUser), :switchUser);
    menu.addItem(WatchUi.loadResource(Rez.Strings.menuAbout), :about);
    if (isSupport()) {
      menu.addItem(
        WatchUi.loadResource(Rez.Strings.server) + ": " + serverUrl,
        :switchServer
      );
    }
  }

  function updateServerUrl(offset as Number) as Void {
    serverUrl = findInList(serverUrl, $.ServerUrls, offset);
  }

  // Lookup current serverUrl in $.ServerUrls, and if found apply offset, wrapped at start/end
  function findInList(
    value as String?,
    list as Array<String>,
    offset as Number
  ) as String {
    var i = 0;
    if (value != null) {
      for (; i < list.size(); ++i) {
        if (value.equals(list[i])) {
          break;
        }
      }
    }
    if (i >= list.size()) {
      // serverUrl not found in list
      i = 0;
    }
    i = i + offset;
    if (i >= list.size()) {
      // new index past end of list
      i = 0;
    } else if (i < 0) {
      // new index below start of list
      i = list.size() - 1;
    }

    return list[i];
  }

  function switchServer() as Void {
    updateServerUrl(1);
    saveProperty(STORE_SERVER_URL, serverUrl);
    accessToken = loadStringProperty(STORE_ACCESS_TOKEN + "-" + serverUrl);
  }
}
