using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.System;
using Toybox.WatchUi as Ui;

class DownloadRequest extends RequestDelegate {

  private var _delegate;
  private var mModel;

  function initialize(delegate) {
    RequestDelegate.initialize();
    mModel = Application.getApp().model;
    _delegate = delegate;
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

  function setupParams() {
      var params = {
      "appVersion" => AppVersion,
      "device" => deviceName(),
      "jsonErrors" => 1 // wrap any response code errors in JSON
    };
    var stepTarget = mModel.stepTargetPref;
    if (stepTarget != null) {
      params["workoutStepTarget"] = stepTarget;
    }
    var stepName = mModel.stepNamePref;
    if (stepName != null) {
      params["workoutStepName"] = stepName;
    }
    var adjustTemperature = mModel.adjustTemperaturePref;
    if (adjustTemperature != null) {
      params["adjustTemperature"] = trueFalse(adjustTemperature);
    }
    var adjustUndulation = mModel.adjustUndulationPref;
    if (adjustUndulation != null) {
      params["adjustUndulation"] = trueFalse(adjustUndulation);
    }
    var includeRunBackStep = mModel.includeRunBackStepPref;
    if (includeRunBackStep != null) {
      params["includeRunBackStep"] = trueFalse(includeRunBackStep);
    }
    return params;
  }

  // SDK 2.4.3 serialises true to "True", which jackson rejects
  function trueFalse(val) {
    return val ? "true" : "false";
  }

  function downloadWorkoutSummary() {
    var url = mModel.serverUrl + "/api/mobile/plannedWorkoutSummary";
    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Authorization" => "Bearer " + mModel.accessToken,
        "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
      },
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    Comm.makeWebRequest(url, setupParams(), options, method(:handleWorkoutSummaryResponse));
  }

  function handleWorkoutSummaryResponse(responseCode, data) {
    // jsonErrors workaround non 200 response codes being flattened out
    if (responseCode == 200 && data["responseCode"] != null) {
      responseCode = data["responseCode"];
    }
    // System.print("handleWorkoutSummaryResponse: " + responseCode + " ");
    // System.println(data);

    if (responseCode != 200) {
      handleErrorResponseCode("summary", responseCode);
    } else if (data == null) {
      Error.showErrorResource(Rez.Strings.noWorkoutSummary);
    } else {
      mModel.updateWorkoutSummary(data);
      downloadWorkout();
    }
  }

  function downloadWorkout() {
    var downloadStatus = mModel.determineDownloadStatus();
    if (downloadStatus != DownloadStatus.OK) {
      noWorkoutDownloaded(downloadStatus);
      return;
    }

    // var url = $mModel.serverUrl + "/api/mobile/plannedWorkoutDownload";
    // var options = {
    //   :method => Comm.HTTP_REQUEST_METHOD_POST,
    //   :headers => {
    //     "Authorization" => "Bearer " + mModel.accessToken,
    //     "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
    //   },
    //   :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_FIT
    // };

    // For now use old request endpoint as setting Comm.REQUEST_CONTENT_TYPE_JSON on a
    // explode on devices (runs fine in simulator)
    var url = mModel.serverUrl + "/api/mobile/plannedWorkout";
    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Authorization" => "Bearer " + mModel.accessToken
      },
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_FIT
    };

    try {
      Comm.makeWebRequest(url, setupParams(), options, method(:handleDownloadWorkoutResponse));
    } catch (e instanceof Lang.SymbolNotAllowedException) {
      Error.showErrorResource(Rez.Strings.errorUnexpectedDownloadError);
    }
  }

  function handleDownloadWorkoutResponse(responseCode, downloads) {
   var download = downloads == null ? null : downloads.next();
    // System.println("handleDownloadWorkoutResponse: " + responseCode + " " + (download == null ? null : download.getName() + "/" + download.getId()));
    if (responseCode == 200) {
      if (download == null) {
        noWorkoutDownloaded(DownloadStatus.NO_WORKOUT);
      } else {
        mModel.setDownload(download);
        showWorkout();
      }
    } else if (responseCode == 0) {
      noWorkoutDownloaded(DownloadStatus.NO_FIT_DATA_RETURNED);
    } else if (responseCode == 403) {   // XXX Never seen on watch hardware as of at least 2.3.4 - flattened to 0
      noWorkoutDownloaded(DownloadStatus.INSUFFICIENT_SUBSCRIPTION_CAPABILITIES);
    } else {
      handleErrorResponseCode("download", responseCode);
    }
  }

  function noWorkoutDownloaded(reason) {
    // System.println("noWorkoutDownloaded: " + reason);
    mModel.setDownloadStatus(reason);
    showWorkout();
  }

  function showWorkout() {
    Ui.switchToView(new WorkoutView(), new WorkoutDelegate(), Ui.SLIDE_IMMEDIATE);
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
