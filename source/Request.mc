using Toybox.WatchUi as Ui;

class RequestDelegate {

  function handleError(message) {
    Ui.switchToView(new ErrorView(message), new ErrorDelegate(), Ui.SLIDE_IMMEDIATE);
  }

  function handleErrorResponseCode(responseCode) {
    switch(responseCode) {
      case -104: // BLE_CONNECTION_UNAVAILABLE
        handleError(Ui.loadResource(Rez.Strings.connectString));
        break;
      case 0: // no data - may be full, or empty FIT returned
        handleError(Ui.loadResource(Rez.Strings.errorNoData));
        break;
      case 401: // Unauthorized
        Ui.switchToView(new GrantView(true, false), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case 403: // Forbidden
        handleError(Ui.loadResource(Rez.Strings.errorAccountCapabilities));
        break;
      case 404: // not found
        handleError(Ui.loadResource(Rez.Strings.errorNotFound));
        break;
      case 418: // service alternately unavailable
      case 503: // service unavailable
        handleError(Ui.loadResource(Rez.Strings.errorServiceUnavailable));
        break;
      default:
        handleError(Ui.loadResource(Rez.Strings.errorResponseCode) + responseCode);
        break;
    }
  }

  function handleResponse(data) {
  }

}
