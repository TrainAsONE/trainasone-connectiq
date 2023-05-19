import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;

class NetUtil {
  static function extractResponseCode(
    responseCode as Number,
    data as Dictionary<String> or String or Null
  ) as Number {
    // workaround non 200 response codes being flattened out by Garmin runtime
    if (responseCode == 200 && data != null && data["responseCode"] != null) {
      return data["responseCode"] as Number;
    }
    return responseCode;
  }
}
