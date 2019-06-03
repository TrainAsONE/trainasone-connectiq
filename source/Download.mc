using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.System;
using Toybox.WatchUi as Ui;

class DownloadRequest extends RequestDelegate {

  private var mModel;
  private var _downloadViewRef;

  function initialize(downloadView) {
    RequestDelegate.initialize();
    mModel = Application.getApp().model;
    _downloadViewRef = downloadView.weak(); // Avoid a circular reference
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
      "device" => System.getDeviceSettings().partNumber,
      "jsonErrors" => 1 // wrap any response code errors in JSON
    };
    var keys = mModel.localPref.keys();
    for (var i = 0; i<keys.size(); ++i ) {
      params[keys[i]] = mModel.localPref[keys[i]];
    }
    // System.println("params: " + params);
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

    // Null-op on at least 735xt as watch shows Garmin "Updating" page automatically
    _downloadViewRef.get().showDownloading();

    // For now use old request endpoint as setting Comm.REQUEST_CONTENT_TYPE_JSON
    // on a FIT endpoint explodes on devices (runs fine in simulator)
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
        System.println("FIT download: null");
        noWorkoutDownloaded(DownloadStatus.RESPONSE_MISSING_WORKOUT_DATA);
      } else {
        mModel.setDownload(download);
	/* A little simulator entertainment:
         * - The following popView seems to be required on the Forerunner 735XT
	 *   otherwise when the user redownloads the workout (for example when
         *   switching settings) each DownloadView will stack, until the widget
         *   runs out of stack and crashes
         *   The 735XT is the only workout download capable watch which cannot
         *   run monkeyVersion 3 or later, so conditionalise on 2.x or earlier
         * - In the simulator calling it will immediately exit the widget,
         *   which matches the behaviour on all other devices, but is obviously
         *   different to the actual hardware. So have a build time define so
         *   the workaround can be switched for when the simulator is used
         */
        if ($.ViewStackWorkaroundPreMonkeyV3 && System.getDeviceSettings().monkeyVersion[0] < 3) {
          Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
        showWorkout();
      }
    } else if (responseCode == 0) {
      System.println("FIT download: response code 0");
      noWorkoutDownloaded(DownloadStatus.RESPONSE_CODE_ZERO);
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

}
