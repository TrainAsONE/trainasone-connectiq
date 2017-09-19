using Toybox.WatchUi as Ui;

class RequestDelegate {

  function handleError(message) {
    Ui.switchToView(new ErrorView(message), null, Ui.SLIDE_IMMEDIATE);
  }

  function handleResponse(data) {
  }

}
