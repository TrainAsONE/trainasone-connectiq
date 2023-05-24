import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:glance)
class TrainAsONEApp extends Application.AppBase {
  var model as TaoModel;

  function initialize() {
    AppBase.initialize();
    log("Starting TrainAsONE " + appVersion());
    model = new TaoModel();
  }

  function appVersion() as String {
    var appVersion = $.AppVersion;
    if (Toybox has :PersistedContent) {
      appVersion += "+d"; // Download capable
      if (PersistedContent has :getAppWorkouts) {
        appVersion += ",o"; // Can manage own set of workouts
      }
    }
    return appVersion;
  }

  // onStart() is called on application start up
  function onStart(state) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state) as Void {}

  function getGlanceView() as Array<GlanceView>? {
    return [new TaoGlanceView()] as Array<GlanceView>;
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    if (!System.getDeviceSettings().phoneConnected) {
      return (
        [
          new MessageView(
            WatchUi.loadResource(Rez.Strings.errorPleaseConnectPhone)
          ),
          new MessageDelegate(null),
        ] as Array<Views or InputDelegates>
      );
    } else if (model.accessToken == null) {
      return (
        [new GrantView(false, false), new GrantDelegate()] as
        Array<Views or InputDelegates>
      );
    } else {
      return (
        [new DownloadView(null), new DownloadDelegate()] as
        Array<Views or InputDelegates>
      );
    }
  }

  function log(message as String) as Void {
    var now = System.getClockTime();
    System.print(
      now.hour.format("%02d") +
        ":" +
        now.min.format("%02d") +
        ":" +
        now.sec.format("%02d") +
        " "
    );
    var array = message.toCharArray();
    for (var i = 0; i < array.size(); ++i) {
      if (array[i] == '\n') {
        array[i] = ' ';
      }
    }
    System.println(StringUtil.charArrayToString(array));
  }
}
