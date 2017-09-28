using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.Lang;
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
        "Authorization" => "Bearer " + App.getApp().getProperty(TaoConstants.OBJ_ACCESS_TOKEN),
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
      handleError(Ui.loadResource(Rez.Strings.noWorkoutsString));
    } else if (data["responseCode"] != null) { // jsonErrors
      handleErrorResponseCode(data["responseCode"]);
    } else {
      _workoutSummary = data;
      downloadDisplayPreferences();
    }
  }

function downloadDisplayPreferences() {
    var url = $.ServerUrl + "/api/mobile/displayPreferences";
    var params = {
      "appVersion" => AppVersion,
      "device" => deviceName(),
      "jsonErrors" => 1 // wrap any response code errors in JSON
    };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Authorization" => "Bearer " + App.getApp().getProperty(TaoConstants.OBJ_ACCESS_TOKEN),
        "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    Communications.makeWebRequest(url, params, options, method(:handleDisplayPreferencesResponse));
  }

  function handleDisplayPreferencesResponse(responseCode, data) {
    Sys.println("handleDisplayPreferencesResponse: " + responseCode + " " + data);
    if (responseCode != 200) {
      handleErrorResponseCode(responseCode);
    } else if (data == null) {
      handleError(Ui.loadResource(Rez.Strings.noWorkoutsString));
    } else if (data["responseCode"] != null) { // jsonErrors
      handleErrorResponseCode(data["responseCode"]);
    } else {
      App.getApp().setProperty(TaoConstants.OBJ_DISPLAY_PREFERENCES, data);
      downloadWorkout();
    }
  }

  function downloadWorkout() {
    if (!(Toybox has :PersistedContent)) {
      downloadWorkoutNotSupported();
      return;
    }

    // var url = $.ServerUrl + "/api/mobile/plannedWorkoutDownload";
    // var options = {
    //   :method => Comm.HTTP_REQUEST_METHOD_POST,
    //   :headers => {
    //     "Authorization" => "Bearer " + App.getApp().getProperty(TaoConstants.OBJ_ACCESS_TOKEN),
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
        "Authorization" => "Bearer " + App.getApp().getProperty(TaoConstants.OBJ_ACCESS_TOKEN)
      },
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_FIT
    };

    try {
      Comm.makeWebRequest(url, params, options, method(:handleDownloadWorkoutResponse));
    } catch (e instanceof Lang.SymbolNotAllowedException) {
      handleError(Ui.loadResource(Rez.Strings.errorUnexpectedDownloadError));
    }
  }

  function handleDownloadWorkoutResponse(responseCode, downloads) {
    if (responseCode == 200) {
      var download = downloads.next();
      if (download == null) {
        handleError(Ui.loadResource(Rez.Strings.noWorkoutsString));
      } else {
        handleDownloadedWorkout(download);
      }
    } else {
      handleErrorResponseCode(responseCode);
    }
  }

  function downloadWorkoutNotSupported() {
    showWorkout(null);
  }

  function handleDownloadedWorkout(download) {
    var workoutIntent = download.toIntent();
    App.getApp().setProperty(TaoConstants.OBJ_WORKOUT_NAME, download.getName());
    showWorkout(download.toIntent());
  }

  function showWorkout(workoutIntent) {
    var previousSummary = App.getApp().getProperty(TaoConstants.OBJ_SUMMARY);
    var updated = previousSummary == null || !previousSummary["name"].equals(_workoutSummary["name"]);
    App.getApp().setProperty(TaoConstants.OBJ_SUMMARY, _workoutSummary);
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
