using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class TrainAsONEApp extends App.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state) {
  }

  // onStop() is called when your application is exiting
  function onStop(state) {
  }

  // Return the initial view of your application here
  function getInitialView() {
    if (!System.getDeviceSettings().phoneConnected) {
      return [ new ErrorView(Ui.loadResource(Rez.Strings.errorPleaseConnectPhone)), new ErrorDelegate() ];
    } else if (Store.getAccessToken() == null) {
      return [ new GrantView(false, false), new GrantDelegate() ];
    } else {
      return [ new DownloadView(), new DownloadDelegate() ];
    }
 }

}
