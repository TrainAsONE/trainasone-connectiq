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
    var params = {
      "appVersion" => AppVersion,
      "device" => deviceName
    };
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
        Ui.switchToView(new ErrorView("Device does\nnot support\nFIT download"), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
      } else {
        Ui.switchToView(new ErrorView("Unexpected workout\ndownload error"), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
      }
    }
  }

  function handleDownloadResponse(responseCode, downloads) {
    switch (responseCode) {
      case 200:
        var download = downloads.next();
        if (download == null) {
          handleError(Ui.loadResource(Rez.Strings.noWorkoutsString));
        } else {
          handleDownloadedWorkout(download);
        }
        break;
      case 401: // Unauthorized
        Ui.switchToView(new GrantView(true, false), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case 403: // Forbidden
        handleError(Ui.loadResource(Rez.Strings.errorAccountCapabilities));
        break;
      default:
        handleError(responseCode);
        break;
    }
  }

  function handleDownloadedWorkout(download) {
    var workoutName = download.getName();
    var workoutIntent = download.toIntent();
    Ui.switchToView(new WorkoutView(workoutName), new WorkoutDelegate(workoutIntent), Ui.SLIDE_IMMEDIATE);
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
