import Toybox.WatchUi;

class GrantDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }
}

class GrantView extends WatchUi.View {
  private var _request;
  private var _reAuth;
  private var _clearAuth;

  function initialize(reAuth, clearAuth) {
    View.initialize();
    _reAuth = reAuth;
    _clearAuth = clearAuth;
  }

  function onLayout(dc) as Void {
    setLayout(Rez.Layouts.StandardLayout(dc));
    var message = WatchUi.loadResource(_reAuth ? Rez.Strings.grantReAuthString : Rez.Strings.grantString);
    var view = View.findDrawableById("message") as WatchUi.Text;
    view.setFont(Graphics.FONT_SMALL);
    view.setText(message);
  }

  function onShow() as Void {
    if (_request == null) {
      _request = new GrantRequest(new GrantRequestDelegate(_clearAuth), _clearAuth);
      _request.start();
    }
  }
}
