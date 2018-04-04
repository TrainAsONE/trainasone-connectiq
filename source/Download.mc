using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class DownloadRequest extends RequestDelegate {
  private var _delegate;
  private var _workoutSummary;

  function initialize(delegate) {
    _delegate = delegate;
    RequestDelegate.initialize();
  }

  // Note on "jsonErrors"
  // Currently (2.3.4) the Simulator does not appear to see any non 220 responseCodes unless the
  // server sets the media type of JSON, and at least the 735xt connected to a Garmin Mobile app
  // doesn't see them even in that case (it repeats the request 20 times and then returns -300)
  // So jsonErrors tells the server to wrap any response code errors in JSON and return them with
  // status 200. Suggestions as to how to better handle this appreciated
  //
  function start() {
    downloadWorkoutSummary();
  }

  function downloadWorkoutSummary() {
    var url = $.ServerUrl + "/api/mobile/plannedWorkoutSummary";
    var params = {
      "appVersion" => AppVersion,
      "device" => deviceName(),
      "jsonErrors" => 1 // wrap any response code errors in JSON
    };
    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Authorization" => "Bearer " + Store.getAccessToken(),
        "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
      },
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    Comm.makeWebRequest(url, params, options, method(:handleWorkoutSummaryResponse));
  }

  function handleWorkoutSummaryResponse(responseCode, data) {
    Sys.println("handleWorkoutSummaryResponse: " + responseCode + " " + data);
    if (responseCode != 200) {
      handleErrorResponseCode(responseCode);
    } else if (data == null) {
      Error.showErrorResource(Rez.Strings.noWorkoutSummary);
    } else if (data["responseCode"] != null) { // jsonErrors
      handleErrorResponseCode(data["responseCode"]);
    } else {
      _workoutSummary = data;
      downloadWorkout();
    }
  }

  function downloadWorkout() {
    if (!(Toybox has :PersistedContent)) {
      noWorkoutDownloaded(TaoConstants.DOWNLOAD_RESULT_UNSUPPORTED);
      return;
    }
    if (!_workoutSummary["downloadPermitted"]) {
      noWorkoutDownloaded(TaoConstants.DOWNLOAD_RESULT_INSUFFICIENT_SUBSCRIPTION_CAPABILITIES);
      return;
    }
    // var url = $.ServerUrl + "/api/mobile/plannedWorkoutDownload";
    // var options = {
    //   :method => Comm.HTTP_REQUEST_METHOD_POST,
    //   :headers => {
    //     "Authorization" => "Bearer " + Store.getAccessToken(),
    //     "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
    //   },
    //   :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_FIT
    // };

    // For now use old request endpoint as setting Comm.REQUEST_CONTENT_TYPE_JSON on a
    // explode on devices (runs fine in simulator)
    var url = $.ServerUrl + "/api/mobile/plannedWorkout";
    var params = {
      "appVersion" => AppVersion,
      "device" => deviceName()
    };

    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Authorization" => "Bearer " + Store.getAccessToken()
      },
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_FIT
    };

    try {
      Comm.makeWebRequest(url, params, options, method(:handleDownloadWorkoutResponse));
    } catch (e instanceof Lang.SymbolNotAllowedException) {
      Error.showErrorResource(Rez.Strings.errorUnexpectedDownloadError);
    }
  }

  function handleDownloadWorkoutResponse(responseCode, downloads) {
    if (responseCode == 200) {
      var download = downloads.next();
      if (download == null) {
        noWorkoutDownloaded(TaoConstants.DOWNLOAD_RESULT_NO_WORKOUT);
      } else {
        handleDownloadedWorkout(download);
      }
    } else if (responseCode == 0) {
      noWorkoutDownloaded(TaoConstants.DOWNLOAD_RESULT_NO_FIT_DATA_LOADED);
    } else if (responseCode == 403) {   // XXX Never seen on watch hardware as of at least 2.3.4 - flattened to 0
      noWorkoutDownloaded(TaoConstants.DOWNLOAD_RESULT_INSUFFICIENT_SUBSCRIPTION_CAPABILITIES);
    } else {
      handleErrorResponseCode(responseCode);
    }
  }

  function noWorkoutDownloaded(reason) {
    Sys.println("noWorkoutDownloaded: " + reason);
    Store.setWorkoutName(null);
    Store.setDownloadResult(reason);
    showWorkout(null);
  }

  function handleDownloadedWorkout(download) {
    Sys.println("handleDownloadedWorkout: " + download.getName());
    var workoutIntent = download.toIntent();
    Store.setWorkoutName(download.getName());
     Store.setDownloadResult(TaoConstants.DOWNLOAD_RESULT_OK);
    showWorkout(download.toIntent());
  }

  function showWorkout(workoutIntent) {
    var previousSummary = Store.getSummary();
    Sys.println("previousSummary: " + previousSummary);
    var updated = previousSummary == null || !previousSummary["name"].equals(_workoutSummary["name"]);
    Store.setSummary(_workoutSummary);
    Ui.switchToView(new WorkoutView(updated), new WorkoutDelegate(workoutIntent), Ui.SLIDE_IMMEDIATE);
  }

  function deviceName() {
    var deviceName = Ui.loadResource(Rez.Strings.deviceName);
    if (deviceName.equals("?")) { // String in default resource
      deviceName = System.getDeviceSettings().partNumber;
    }
    return deviceName;
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
