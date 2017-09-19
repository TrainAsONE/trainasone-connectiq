using Toybox.WatchUi as Ui;

class RequestDelegate {

  function handleError(message) {
    Ui.switchToView(new ErrorView(message), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
  }

  function handleResponse(data) {
  }

}
