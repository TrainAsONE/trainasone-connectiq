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

  function start() {
    var url = $.ServerUrl + "/api/mobile/plannedWorkoutSummary";
    var params = {
      "appVersion" => AppVersion,
      "device" => deviceName()
    };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Authorization" => "Bearer " + App.getApp().getProperty("access_token")
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    Communications.makeWebRequest(url, params, options, method(:handleDownloadCheckResponse));
  }

  function handleDownloadCheckResponse(responseCode, data) {
   if (responseCode == 200) {
      if (data == null) {
        handleError(Ui.loadResource(Rez.Strings.noWorkoutsString));
      } else {
        downloadWorkout(data);
      }
    } else {
      handleErrorResponseCode(responseCode);
    }
  }

  function downloadWorkout(workoutSummary) {
    _workoutSummary = workoutSummary;

    if (!(Toybox has :PersistedContent)) {
      downloadWorkoutNotSupported();
    } else {
      var url = $.ServerUrl + "/api/mobile/plannedWorkoutDownload";
      var params = {
        "appVersion" => AppVersion,
        "device" => deviceName()
      };
      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => {
          "Authorization" => "Bearer " + App.getApp().getProperty("access_token")
        },
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_FIT
      };
      try {
        Communications.makeWebRequest(url, params, options, method(:handleDownloadWorkoutResponse));
      } catch (e instanceof Lang.SymbolNotAllowedException) {
        // XXX It would be nice if there was a better way to test for this specific error
        if (e.getErrorMessage().equals("Invalid value for :responseType for this device.")) {
          downloadWorkoutNotSupported();
        } else {
          handleError(Ui.loadResource(Rez.Strings.errorUnexpectedDownloadError));
        }
      }
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
    App.getApp().setProperty("workout_key", download.getName());
    showWorkout(download.toIntent());
  }

  function showWorkout(workoutIntent) {
    var workoutName = _workoutSummary["name"];
    var previousWorkoutName = App.getApp().getProperty("workout_name");
    var updated = previousWorkoutName == null || !previousWorkoutName.equals(workoutName);
    App.getApp().setProperty("workout_name", workoutName);
    App.getApp().setProperty("workout_start", _workoutSummary["start"]);
    Ui.switchToView(new WorkoutView(updated), new WorkoutDelegate(workoutIntent), Ui.SLIDE_IMMEDIATE);
  }

  function deviceName() {
    var deviceName = Ui.loadResource(Rez.Strings.deviceName);
    if (deviceName.equals("")) {
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
