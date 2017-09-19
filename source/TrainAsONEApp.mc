using Toybox.Application as App;
using Toybox.System as Sys;

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
      return [new ConnectView() ];
    } else if (getProperty("access_token") == null) {
      return [ new GrantView(false, false), new GrantDelegate() ];
    } else {
      return [ new DownloadView(), new DownloadDelegate() ];
    }
 }

}
