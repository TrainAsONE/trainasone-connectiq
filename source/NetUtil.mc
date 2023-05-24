import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

/// This should really all be just static functions, but
/// System.getDeviceSettings().partNumber cannot be called in a static
// function with Type Checking enabled (SDK 4.2.4)
class NetUtil {
  function extractResponseCode(
    responseCode as Number,
    data as Dictionary or String or Null
  ) as Number {
    // workaround non 200 response codes being flattened out by Garmin runtime
    if (responseCode == 200 && data != null && data["responseCode"] != null) {
      return data["responseCode"] as Number;
    }
    return responseCode;
  }

  function deviceParams() as Dictionary {
    var deviceSettings = System.getDeviceSettings();
    var appVersion = $.AppVersion;
    if (Toybox has :PersistedContent) {
      appVersion += "+full";
    }
    var device =
      deviceSettings.partNumber +
      Lang.format("/$1$.$2$.$3$", deviceSettings.monkeyVersion);

    return {
      "appVersion" => appVersion,
      "device" => device,
    };
  }
}
