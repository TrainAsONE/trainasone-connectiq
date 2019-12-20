using Toybox.WatchUi as Ui;

class DownloadDelegate extends Ui.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class DownloadView extends Ui.View {
  private var _message;
  private var _stateText;
  private var _request;

  function initialize(message) {
    View.initialize();
    _message = (message != null ? message : "Checking workout");
    _stateText = "connecting";
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.StandardLayout(dc));
    showMessage();
  }

  function onShow() {
    if (_request == null) {
      _request = new DownloadRequest(self);
      _request.start();
    }
  }

  function updateState(stateText) {
    _stateText = stateText;
    showMessage();
  }

  function showMessage() {
    System.println("download: " + _message + ": " + _stateText);
    View.findDrawableById("message").setText(_message + "\n(" + _stateText + ")");
  }

}
