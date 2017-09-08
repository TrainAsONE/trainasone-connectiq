using Toybox.WatchUi;

class ConnectView extends WatchUi.View {

  // XXX Should prompt for select then recheck status

  function initialize() {
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.ConnectLayout(dc));
  }

}
