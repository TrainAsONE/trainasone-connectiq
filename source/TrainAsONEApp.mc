import Toybox.Application;
import Toybox.System;
import Toybox.WatchUi;

(:glance)
class TrainAsONEApp extends Application.AppBase {

  var model;

  function initialize() {
    AppBase.initialize();
    log("Starting TrainAsONE " + AppVersion);
    model = new TaoModel();
  }

  // onStart() is called on application start up
  function onStart(state) as Void {
  }

  // onStop() is called when your application is exiting
  function onStop(state) as Void {
  }

   function getGlanceView() {
     return [ new GlanceView() ];
   }

  // Return the initial view of your application here
  function getInitialView() {
    if (!System.getDeviceSettings().phoneConnected) {
      return [ new MessageView(WatchUi.loadResource(Rez.Strings.errorPleaseConnectPhone)), new MessageDelegate(null) ];
    } else if (model.accessToken == null) {
      return [ new GrantView(false, false), new GrantDelegate() ];
    } else {
      return [ new DownloadView(null), new DownloadDelegate() ];
    }
  }

  function log(message) {
    var now = System.getClockTime();
    System.print(now.hour.format("%02d") + ":" + now.min.format("%02d") + ":" + now.sec.format("%02d") + " ");
    System.println(message);
  }

}
