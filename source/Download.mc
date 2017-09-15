using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

class DownloadRequest extends RequestDelegate {
  private var _delegate;

  function initialize(delegate) {
    _delegate = delegate;
    RequestDelegate.initialize();
  }

  function start() {
    var url = $.ServerUrl + "/api/mobile/plannedWorkout";
    var params = { "a" => 2 };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Authorization" => "Bearer " + App.getApp().getProperty("access_token")
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_FIT
    };
    Communications.makeWebRequest(url, params, options, method(:handleDownloadResponse));
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
