using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class DownloadRequest extends RequestDelegate {
  private var _delegate;

  function initialize(delegate) {
    _delegate = delegate;
    RequestDelegate.initialize();
  }

  function start() {
    var deviceName = Ui.loadResource(Rez.Strings.deviceName);
    if (deviceName.equals("")) {
      deviceName = System.getDeviceSettings().partNumber;
    }

    var url = $.ServerUrl + "/api/mobile/plannedWorkout";
    var params = { "device" => deviceName };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Authorization" => "Bearer " + App.getApp().getProperty("access_token")
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_FIT
    };
    try {
      Communications.makeWebRequest(url, params, options, method(:handleDownloadResponse));
    } catch (e instanceof Lang.SymbolNotAllowedException) {
      // XXX It would be nice if there was a better way to test for this specific error
      if (e.getErrorMessage().equals("Invalid value for :responseType for this device.")) {
        Ui.switchToView(new ErrorView("Device does\nnot support\nFIT download"), null, Ui.SLIDE_IMMEDIATE);
      } else {
        Ui.switchToView(new ErrorView("Unexpected workout\ndownload error"), null, Ui.SLIDE_IMMEDIATE);
      }
    }
  }

  function handleDownloadResponse(responseCode, downloads) {
    if (responseCode == 403) { // ReGrant needed
      Ui.switchToView(new GrantView(true, false), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
    } else if (responseCode == 200) {
      var download = downloads.next();
      if (download == null) {
        handleError(Ui.loadResource(Rez.Strings.noWorkoutsString));
      } else {
        Ui.switchToView(new WorkoutView(download.getName()), new WorkoutDelegate(download.toIntent()), Ui.SLIDE_IMMEDIATE);
      }
    } else {
      handleError(responseCode);
    }
  }

}

class DownloadRequestDelegate extends RequestDelegate {

  // Constructor
  function initialize() {
    RequestDelegate.initialize();
  }

  // Handle a successful response from the server
  function handleResponse(data) {
    Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
  }

}
