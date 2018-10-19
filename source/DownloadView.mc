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
    _message = message != null ? message + "\n(updating workout)" : "Next workout\n(updating)";
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.StandardLayout(dc));
    var view = View.findDrawableById("message");
    view.setText(_message);
  }

  function onShow() {
    if (_request == null) {
      _request = new DownloadRequest();
      _request.start();
    }
  }
}
