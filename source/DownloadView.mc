using Toybox.WatchUi as Ui;

class DownloadDelegate extends Ui.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class DownloadView extends Ui.View {
  private var _message;
  private var _request;

  function initialize(message) {
    View.initialize();
    _message = (message != null ? message : "Next workout") + "\n(updating from server)";
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.StandardLayout(dc));
    View.findDrawableById("message").setText(_message);
  }

  function onShow() {
    if (_request == null) {
      _request = new DownloadRequest();
      _request.start();
    }
  }
}
