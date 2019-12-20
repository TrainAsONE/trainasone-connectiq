using Toybox.Application;
using Toybox.System;
using Toybox.WatchUi as Ui;

(:glance)
class TrainAsONEApp extends Application.AppBase {

  var model;

  function initialize() {
    AppBase.initialize();
    log("Starting TrainAsONE " + AppVersion);
    model = new TaoModel();
  }

  // onStart() is called on application start up
  function onStart(state) {
  }

  // onStop() is called when your application is exiting
  function onStop(state) {
  }

   function getGlanceView() {
     return [ new GlanceView() ];
   }

  // Return the initial view of your application here
  function getInitialView() {
    if (!System.getDeviceSettings().phoneConnected) {
      return [ new ErrorView(Ui.loadResource(Rez.Strings.errorPleaseConnectPhone)), new ErrorDelegate() ];
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
