using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.Lang;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

class DownloadRequest extends RequestDelegate {

  const downloadTimeout = 19;
  private var mModel;
  private var _downloadViewRef;
  private var _downloadResponseCalled = false;
  private var _downloadTimer;
  private var _downloadTimerCount;

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

  function downloadWorkoutSummary() {
    var url = mModel.serverUrl + "/api/mobile/plannedWorkoutSummary";
    var params = setupParams();
    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Authorization" => "Bearer " + mModel.accessToken,
        "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
      },
      :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    };
    updateState("fetching summary");
    try {
      Comm.makeWebRequest(url, params, options, method(:onDownloadWorkoutSummaryResponse));
    } catch (e) {
      Message.showErrorResource(Rez.Strings.errorUnexpectedUpdateError);
    }
  }

  function onDownloadWorkoutSummaryResponse(responseCode, data) as Void {
    updateState("updating summary");
    // jsonErrors workaround non 200 response codes being flattened out
    if (responseCode == 200 && data["responseCode"] != null) {
      responseCode = data["responseCode"];
    }
    // Application.getApp().log("onDownloadWorkoutSummaryResponse: " + responseCode + " " + data);

    if (responseCode != 200) {
      handleErrorResponseCode("summary", responseCode);
    } else if (data == null) {
      Message.showErrorResource(Rez.Strings.noWorkoutSummary);
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

    // Null-op on at least 735xt as watch shows Garmin "Updating" page automatically
    updateState("request download");

    // var url = $mModel.serverUrl + "/api/mobile/plannedWorkoutDownload";
    // var options = {
    //   :method => Comm.HTTP_REQUEST_METHOD_POST,
    //   :headers => {
    //     "Authorization" => "Bearer " + mModel.accessToken,
    //     "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
    //   },
    //   :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_FIT
    // };

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

    startDownloadTimer();

    try {
      Comm.makeWebRequest(url, setupParams(), options, method(:onDownloadWorkoutResponse));
    } catch (e instanceof Lang.SymbolNotAllowedException) {
      Message.showErrorResource(Rez.Strings.errorUnexpectedDownloadNotAllowedError);
    } catch (e) {
      Message.showErrorResource(Rez.Strings.errorUnexpectedDownloadError);
    }
    updateState("downloading");
  }

  // _downloadTimerCount is always stopped before we finish
  // either onDownloadWorkoutResponse is called, or onDownloadTimeout hits its count limit
  function startDownloadTimer() {
    _downloadTimer = new Timer.Timer();
    _downloadTimerCount = 0;
    _downloadTimer.start(method(:onDownloadTimeout), 1000 , true);
  }

  // On 245 & 945 firmware 3.90 the download never completes
  function onDownloadTimeout() as Void {
    ++_downloadTimerCount;
    Application.getApp().log("downloadTimer " + _downloadTimerCount);
    if (_downloadTimerCount > downloadTimeout && !_downloadResponseCalled) {
      _downloadTimer.stop();
      updateState("download timeout");
      mModel.setWorkoutMessageResource(Rez.Strings.downloadTimeout);
      noWorkoutDownloaded(DownloadStatus.DOWNLOAD_TIMEOUT);
    }
  }

  function onDownloadWorkoutResponse(responseCode, downloads) as Void {
    _downloadResponseCalled = true;
    _downloadTimer.stop();

    updateState("saving");
    var download = downloads == null ? null : downloads.next();
    // Application.getApp().log("handleDownloadWorkoutResponse: " + responseCode + " " + (download == null ? null : download.getName() + "/" + download.getId()));
    if (responseCode == 200) {
      if (download == null) {
        Application.getApp().log("FIT download: null");
        mModel.setWorkoutMessageResource(Rez.Strings.noWorkoutSpace);
        noWorkoutDownloaded(DownloadStatus.RESPONSE_MISSING_WORKOUT_DATA);
      } else {
        mModel.updateDownload(download);
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
         *   we can exclude the device uniqueIdentifer returned by the Simulator
         */
        var deviceSettings = System.getDeviceSettings();
        // Application.getApp().log("uniqueIdentifier(" + deviceSettings.uniqueIdentifier + ")");
        if (deviceSettings.monkeyVersion[0] < 3 && !deviceSettings.uniqueIdentifier.equals($.ExcludeViewStackWorkaroundPreMonkeyV3)) {
          Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
        showWorkout();
      }
    } else if (responseCode == 0) {
      Application.getApp().log("FIT download: response code 0");
      mModel.setWorkoutMessageResource(Rez.Strings.noWorkoutSpace);
      noWorkoutDownloaded(DownloadStatus.RESPONSE_CODE_ZERO);
    } else if (responseCode == 403) {   // XXX Never seen on watch hardware as of at least 2.3.4 - flattened to 0
      noWorkoutDownloaded(DownloadStatus.INSUFFICIENT_SUBSCRIPTION_CAPABILITIES);
    } else {
      handleErrorResponseCode("download", responseCode);
    }
  }

  function noWorkoutDownloaded(reason) {
    Application.getApp().log("noWorkoutDownloaded: " + reason);
    mModel.setDownloadStatus(reason);
    showWorkout();
  }

  function showWorkout() {
    Ui.switchToView(new WorkoutView(), new WorkoutDelegate(), Ui.SLIDE_IMMEDIATE);
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
    Application.getApp().log("params: " + params);
    return params;
  }

  function updateState(stateText) {
   if(_downloadViewRef.stillAlive()) {
      _downloadViewRef.get().updateState(stateText);
    }
  }

}
