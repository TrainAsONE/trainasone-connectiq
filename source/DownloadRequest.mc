import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.PersistedContent;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class DownloadRequest extends RequestDelegate {
  const downloadTimeout = 19;
  private var mModel as TaoModel;
  private var _downloadViewRef as WeakReference;
  private var _downloadResponseCalled as Boolean = false;
  private var _downloadTimer as Timer.Timer = new Timer.Timer();
  private var _downloadTimerCount as Number = 0;

  function initialize(downloadView as DownloadView) {
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
  function start() as Void {
    downloadWorkoutSummary();
  }

  function downloadWorkoutSummary() as Void {
    var url = mModel.serverUrl + "/api/mobile/plannedWorkoutSummary";
    var params = setupParams();
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Authorization" => "Bearer " + mModel.accessToken,
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
    };
    updateState("fetching summary");
    try {
      Communications.makeWebRequest(
        url,
        params,
        options,
        method(:onDownloadWorkoutSummaryResponse)
      );
    } catch (e) {
      MessageUtil.showErrorResource(Rez.Strings.errorUnexpectedUpdateError);
    }
  }

  function onDownloadWorkoutSummaryResponse(
    responseCode as Number,
    data as Dictionary<String> or String or Null
  ) as Void {
    updateState("updating summary");
    responseCode = NetUtil.extractResponseCode(responseCode, data);
    if (responseCode != 200) {
      handleErrorResponseCode("summary", responseCode);
    } else if (data == null) {
      MessageUtil.showErrorResource(Rez.Strings.noWorkoutSummary);
    } else {
      mModel.updateWorkoutSummary(data);
      downloadWorkout();
    }
  }

  function downloadWorkout() as Void {
    var downloadStatus = mModel.determineDownloadStatus();
    if (downloadStatus != DownloadStatus.OK) {
      noWorkoutDownloaded(downloadStatus);
      return;
    }

    // Null-op on at least 735xt as watch shows Garmin "Updating" page automatically
    updateState("request download");

    // var url = $mModel.serverUrl + "/api/mobile/plannedWorkoutDownload";
    // var options = {
    //   :method => Communications.HTTP_REQUEST_METHOD_POST,
    //   :headers => {
    //     "Authorization" => "Bearer " + mModel.accessToken,
    //     "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
    //   },
    //   :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_FIT
    // };

    // For now use old request endpoint as setting Communications.REQUEST_CONTENT_TYPE_JSON
    // on a FIT endpoint explodes on devices (runs fine in simulator)
    var url = mModel.serverUrl + "/api/mobile/plannedWorkout";
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => {
        "Authorization" => "Bearer " + mModel.accessToken,
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_FIT,
    };

    // _downloadTimerCount is always stopped before we finish
    // either onDownloadWorkoutResponse is called, or onDownloadTimeout hits its count limit
    _downloadTimer.start(method(:onDownloadTimeout), 1000, true);

    try {
      Communications.makeWebRequest(
        url,
        setupParams(),
        options,
        method(:onDownloadWorkoutResponse)
      );
    } catch (e instanceof Lang.SymbolNotAllowedException) {
      MessageUtil.showErrorResource(
        Rez.Strings.errorUnexpectedDownloadNotAllowedError
      );
    } catch (e) {
      MessageUtil.showErrorResource(Rez.Strings.errorUnexpectedDownloadError);
    }
    updateState("downloading");
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

  /// XXX Workaround Garmin Type Check mismatch, pending update from Garmin
  private function asPersistentContentIterator(
    value as Object?
  ) as PersistedContent.Iterator? {
    return value instanceof PersistedContent.Iterator
      ? value as PersistedContent.Iterator
      : null;
  }

  function onDownloadWorkoutResponse(
    responseCode as Number,
    data as Null or Dictionary or String
  ) as Void {
    _downloadResponseCalled = true;
    _downloadTimer.stop();
    var downloads = asPersistentContentIterator(data);
    updateState("saving");
    var download = downloads == null ? null : downloads.next();
    // Application.getApp().log("handleDownloadWorkoutResponse: " + responseCode + " " + (download == null ? null : download.getName() + "/" + download.getId()));
    if (responseCode == 200) {
      if (download == null) {
        Application.getApp().log("FIT download: null");
        mModel.setWorkoutMessageResource(Rez.Strings.noWorkoutSpace);
        noWorkoutDownloaded(DownloadStatus.RESPONSE_MISSING_WORKOUT_DATA);
      } else {
        mModel.updateDownload(download as Workout);
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
        if (
          deviceSettings.monkeyVersion[0] < 3 &&
          deviceSettings.uniqueIdentifier != null &&
          !deviceSettings.uniqueIdentifier.equals(
            $.ExcludeViewStackWorkaroundPreMonkeyV3
          )
        ) {
          WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        showWorkout();
      }
    } else if (responseCode == 0) {
      Application.getApp().log("FIT download: response code 0");
      mModel.setWorkoutMessageResource(Rez.Strings.noWorkoutSpace);
      noWorkoutDownloaded(DownloadStatus.RESPONSE_CODE_ZERO);
    } else if (responseCode == 403) {
      // XXX Never seen on watch hardware as of at least 2.3.4 - flattened to 0
      noWorkoutDownloaded(
        DownloadStatus.INSUFFICIENT_SUBSCRIPTION_CAPABILITIES
      );
    } else {
      handleErrorResponseCode("download", responseCode);
    }
  }

  function noWorkoutDownloaded(reason as Number) as Void {
    Application.getApp().log("noWorkoutDownloaded: " + reason);
    mModel.setDownloadStatus(reason);
    showWorkout();
  }

  function showWorkout() as Void {
    WatchUi.switchToView(
      new WorkoutView(),
      new WorkoutDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  function setupParams() as Dictionary<String, String or Number or Boolean> {
    var params = {
      "appVersion" => AppVersion,
      "device" => System.getDeviceSettings().partNumber,
      "jsonErrors" => 1, // wrap any response code errors in JSON
    };
    var keys = mModel.localPref.keys();
    for (var i = 0; i < keys.size(); ++i) {
      params[keys[i]] = mModel.localPref[keys[i]];
    }
    Application.getApp().log("params: " + params);
    return params;
  }

  function updateState(stateText as String) as Void {
    if (_downloadViewRef.stillAlive()) {
      var downloadView = _downloadViewRef.get() as DownloadView?;
      if (downloadView != null) {
        downloadView.updateState(stateText);
      }
    }
  }
}
