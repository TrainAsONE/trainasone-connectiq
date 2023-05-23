import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;

class RequestDelegate {
  function handleErrorResponseCode(action as String, responseCode as Number) as Void {
    switch (responseCode) {
      case Communications.BLE_ERROR:
      case Communications.BLE_HOST_TIMEOUT:
      case Communications.BLE_SERVER_TIMEOUT:
      case Communications.BLE_NO_DATA:
      case Communications.BLE_REQUEST_CANCELLED:
      case Communications.BLE_QUEUE_FULL:
      case Communications.BLE_REQUEST_TOO_LARGE:
      case Communications.BLE_UNKNOWN_SEND_ERROR:
        MessageUtil.showErrorMessage(
          WatchUi.loadResource(Rez.Strings.errorPhoneConnection) +
            " " +
            responseCode +
            " " +
            action
        );
        break;
      case Communications.BLE_CONNECTION_UNAVAILABLE:
        MessageUtil.showErrorResource(Rez.Strings.errorPleaseConnectPhone);
        break;
      case Communications.NETWORK_REQUEST_TIMED_OUT:
        MessageUtil.showErrorResource(Rez.Strings.errorNetworkRequestTimedOut);
      case 0: // no data - may be full, or empty FIT returned
        MessageUtil.showErrorResource(Rez.Strings.errorNoData);
        break;
      case 401: // Unauthorized
        WatchUi.switchToView(
          new GrantView(true, false),
          new GrantDelegate(),
          WatchUi.SLIDE_IMMEDIATE
        );
        break;
      case 404: // not found
        MessageUtil.showErrorResource(Rez.Strings.errorNotFound);
        break;
      case 418: // service alternately unavailable
      case 503: // service unavailable
        MessageUtil.showErrorResource(Rez.Strings.errorServiceUnavailable);
        break;
      default:
        MessageUtil.showErrorMessage(
          WatchUi.loadResource(Rez.Strings.serverError) +
            " " +
            responseCode +
            " " +
            action
        );
        break;
    }
  }
}
