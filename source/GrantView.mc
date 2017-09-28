using Toybox.WatchUi as Ui;

class GrantDelegate extends Ui.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class GrantView extends Ui.View {
  private var _request;
  private var _reAuth;
  private var _clearAuth;

  function initialize(reAuth, clearAuth) {
    View.initialize();
    _reAuth = reAuth;
    _clearAuth = clearAuth;
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.GrantLayout(dc));
    var message = Ui.loadResource(_reAuth ? Rez.Strings.grantReAuthString : Rez.Strings.grantString);
    View.findDrawableById("message").setText(message);
  }

  function onShow() {
    if (_request == null) {
      _request = new GrantRequest(new GrantRequestDelegate(_clearAuth), _clearAuth);
      _request.start();
    }
  }
}
