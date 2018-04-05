using Toybox.Application as App;
using Toybox.System as Sys;

const STORE_ACCESS_TOKEN = "accessToken";
const STORE_SUMMARY = "summary";
const STORE_WORKOUT_NAME = "workoutName";
const STORE_DOWNLOAD_RESULT = "downloadResult";
const STORE_STEP_TARGET = "stepTarget";
const STORE_ADJUST_TEMPERATURE = "adjustTemperature";
const STORE_ADJUST_UNDULATION = "adjustUndulation";

class Store {
  static function getAccessToken() {
    return App.getApp().getProperty(STORE_ACCESS_TOKEN);
  }

  static function setAccessToken(accessToken) {
    App.getApp().setProperty(STORE_ACCESS_TOKEN, accessToken);
  }

  static function getDownloadResult() { return App.getApp().getProperty(STORE_DOWNLOAD_RESULT); }
  static function setDownloadResult(downloadResult) { App.getApp().setProperty(STORE_DOWNLOAD_RESULT, downloadResult); }

  static function getStepTarget() { return App.getApp().getProperty(STORE_STEP_TARGET); }
  static function setStepTarget(stepTarget) { App.getApp().setProperty(STORE_STEP_TARGET, stepTarget); }

  static function getSummary() { return App.getApp().getProperty(STORE_SUMMARY); }
  static function setSummary(summary) { App.getApp().setProperty(STORE_SUMMARY, summary); }

  static function getAdjustTemperature() { return App.getApp().getProperty(STORE_ADJUST_TEMPERATURE); }
  static function setAdjustTemperature(adjustTemperature) { App.getApp().setProperty(STORE_ADJUST_TEMPERATURE, adjustTemperature); }

  static function getAdjustUndulation() { return App.getApp().getProperty(STORE_ADJUST_UNDULATION); }
  static function setAdjustUndulation(adjustUndulation) { App.getApp().setProperty(STORE_ADJUST_UNDULATION, adjustUndulation); }

  static function getWorkoutName() { return App.getApp().getProperty(STORE_WORKOUT_NAME); }
  static function setWorkoutName(workoutName) { App.getApp().setProperty(STORE_WORKOUT_NAME, workoutName); }

  static function getDisplayPreferences() {
    var summary = getSummary();
    return summary == null ? null : summary["displayPreferences"];
  }

  static function getDisplayPreferencesStepTarget() {
    return getDisplayPreferences()["stepTarget"];
  }

  static function getMergedStepTarget() {
    var stepTarget = getStepTarget();
    return stepTarget == null ? getDisplayPreferences()["stepTarget"] : stepTarget;
  }

  static function getMergedAdjustTemperature() {
    var adjustTemperature = getAdjustTemperature();
    return adjustTemperature == null ? getDisplayPreferences()["eapTemperature"] : adjustTemperature;
  }

  static function getMergedAdjustUndulation() {
    var adjustUndulation = getAdjustUndulation();
    return adjustUndulation == null ? getDisplayPreferences()["eapUndulation"] : adjustUndulation;
  }

  // For now key off the downloadPermitted setting
  static function getAdjustPermitted() {
    return getSummary()["downloadPermitted"];
  }

 }
