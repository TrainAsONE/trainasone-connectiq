using Toybox.WatchUi as Ui;

class GrantDelegate extends Ui.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class GrantView extends Ui.View {
  private var _request;

  function initialize() {
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.GrantLayout(dc));
  }

  function onShow() {
    if (_request == null) {
      _request = new GrantRequest(new GrantRequestDelegate());
      _request.start();
    }
  }
}
