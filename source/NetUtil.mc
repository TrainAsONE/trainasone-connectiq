import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class NetUtil {
  public static function extractResponseCode(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Number {
    // workaround non 200 response codes being flattened out by Garmin runtime
    if (responseCode == 200 && data != null && data["responseCode"] != null) {
      return data["responseCode"] as Number;
    }
    return responseCode;
  }

  public static function deviceParams() as Dictionary {
    var deviceSettings = System.getDeviceSettings();
    var appVersion = Application.getApp().appVersion();
    var device =
      deviceSettings.partNumber +
      Lang.format("/$1$.$2$.$3$", deviceSettings.monkeyVersion);

    return {
      "appVersion" => appVersion,
      "device" => device,
    };
  }
}
