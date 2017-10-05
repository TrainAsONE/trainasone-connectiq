module TaoConstants {
  public const OBJ_ACCESS_TOKEN = "accessToken";
  public const OBJ_DISPLAY_PREFERENCES = "displayPreferences";
  public const OBJ_SUMMARY = "summary";
  public const OBJ_WORKOUT_NAME = "workoutName";
  public const OBJ_DOWNLOAD_RESULT = "downloadResult";

  enum {
    DOWNLOAD_RESULT_OK = 0,
    DOWNLOAD_RESULT_INSUFFICIENT_SUBSCRIPTION_CAPABILITIES = 1,
    DOWNLOAD_RESULT_NO_WORKOUT_STEPS = 2,
    DOWNLOAD_RESULT_UNSUPPORTED = 3,
    DOWNLOAD_RESULT_NO_FIT_DATA_LOADED = 4
  }
}