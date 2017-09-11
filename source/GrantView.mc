using Toybox.WatchUi as Ui;

class GrantDelegate extends Ui.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class GrantView extends Ui.View {
  private var _request;
  private var _reAuth;

  function initialize(reAuth) {
    View.initialize();
    _reAuth = reAuth;
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.GrantLayout(dc));
    var message = Ui.loadResource(_reAuth ? Rez.Strings.grantReAuthString : Rez.Strings.grantString);
    View.findDrawableById("message").setText(message);
  }

  function onShow() {
    if (_request == null) {
      _request = new GrantRequest(new GrantRequestDelegate());
      _request.start();
    }
  }
}
