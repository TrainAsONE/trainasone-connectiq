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
    _message = (message != null ? message : "Checking workout");
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.StandardLayout(dc));
    View.findDrawableById("message").setText(_message  + "\n(updating from server)");
  }

  function showDownloading() {
    View.findDrawableById("message").setText(_message  + "\n(downloading workout)");
  }

  function onShow() {
    if (_request == null) {
      _request = new DownloadRequest(self);
      _request.start();
    }
  }
}
