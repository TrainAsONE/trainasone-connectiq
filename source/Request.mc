using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class RequestDelegate {

  function handleErrorResponseCode(action, responseCode) {
    switch(responseCode) {
      case Comm.BLE_ERROR:
      case Comm.BLE_HOST_TIMEOUT:
      case Comm.BLE_SERVER_TIMEOUT:
      case Comm.BLE_NO_DATA:
      case Comm.BLE_REQUEST_CANCELLED:
      case Comm.BLE_QUEUE_FULL:
      case Comm.BLE_REQUEST_TOO_LARGE:
      case Comm.BLE_UNKNOWN_SEND_ERROR:
        Error.showErrorMessage(Ui.loadResource(Rez.Strings.errorPhoneConnection) + " " + responseCode + " " + action);
        break;
      case Comm.BLE_CONNECTION_UNAVAILABLE:
        Error.showErrorResource(Rez.Strings.errorPleaseConnectPhone);
        break;
      case 0: // no data - may be full, or empty FIT returned
        Error.showErrorResource(Rez.Strings.errorNoData);
        break;
      case 401: // Unauthorized
        Ui.switchToView(new GrantView(true, false), new GrantDelegate(), Ui.SLIDE_IMMEDIATE);
        break;
      case 404: // not found
        Error.showErrorResource(Rez.Strings.errorNotFound);
        break;
      case 418: // service alternately unavailable
      case 503: // service unavailable
        Error.showErrorResource(Rez.Strings.errorServiceUnavailable);
        break;
      default:
        Error.showErrorMessage(Ui.loadResource(Rez.Strings.errorResponse) + " " + responseCode + " " + action);
        break;
    }
  }

  function handleResponse(data) {
  }

}
