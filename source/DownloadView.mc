using Toybox.WatchUi as Ui;

class DownloadDelegate extends Ui.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class DownloadView extends Ui.View {
  private var _request;

  function initialize() {
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.DownloadLayout(dc));
  }

  function onShow() {
    if (_request == null) {
      _request = new DownloadRequest(new DownloadRequestDelegate());
      _request.start();
    }
  }
}
