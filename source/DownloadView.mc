import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DownloadDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class DownloadView extends WatchUi.View {
  private var _message as String?;
  private var _stateText as String = "";
  private var _request as DownloadRequest?;

  function initialize(message as String?) {
    View.initialize();
    _message = message != null ? message : "Checking workout";
  }

  function onLayout(dc as Graphics.Dc) as Void {
    setLayout(Rez.Layouts.StandardLayout(dc));
  }

  function onShow() as Void {
    if (_request == null) {
      updateState("connecting");
      _request = new DownloadRequest(self);
      _request.start();
    }
  }

  function updateState(stateText as String) as Void {
    _stateText = stateText;
    Application.getApp().log("download: " + _message + ": " + _stateText);
    (View.findDrawableById("message") as WatchUi.Text).setText(
      _message + "\n(" + _stateText + ")"
    );
    WatchUi.requestUpdate();
  }
}
