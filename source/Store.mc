using Toybox.Application as App;
using Toybox.System as Sys;

const STORE_ACCESS_TOKEN = "accessToken";
const STORE_SUMMARY = "summary";
const STORE_WORKOUT_NAME = "workoutName";
const STORE_DOWNLOAD_RESULT = "downloadResult";

class Store {
  static function getAccessToken() {
    return App.getApp().getProperty(STORE_ACCESS_TOKEN);
  }
  
  static function setAccessToken(accessToken) {
    App.getApp().setProperty(STORE_ACCESS_TOKEN, accessToken);
  }

  static function getDownloadResult() { return App.getApp().getProperty(STORE_DOWNLOAD_RESULT); }
  static function setDownloadResult(downloadResult) { App.getApp().setProperty(STORE_DOWNLOAD_RESULT, downloadResult); }
  
  static function getSummary() { return App.getApp().getProperty(STORE_SUMMARY); }
  static function setSummary(summary) { App.getApp().setProperty(STORE_SUMMARY, summary); }
  
  static function getWorkoutName() { return App.getApp().getProperty(STORE_WORKOUT_NAME); }
  static function setWorkoutName(workoutName) { App.getApp().setProperty(STORE_WORKOUT_NAME, workoutName); }
  
}