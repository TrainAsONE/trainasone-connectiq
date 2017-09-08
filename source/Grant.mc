using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

const RedirectUri = "https://localhost";
const Scope = "TAO_MOBILE";

// Obtain and store an Oauth2 token for API access
class GrantRequest
{
  private var _delegate;

  function initialize(delegate) {
    _delegate = delegate;
    Comm.registerForOAuthMessages(method(:handleAccessCodeResult)); // May fire immediately
  }

  function start() {
    var requestUrl = $.ServerUrl + "/oauth/authorise";
    var requestParams = {
      "client_id" => $.ClientId,
      "response_type" => "code",
      "scope" => $.Scope,
      "redirect_uri" => $.RedirectUri
    };
    var resultUrl = $.RedirectUri;
    var resultType = Comm.OAUTH_RESULT_TYPE_URL;
    var resultKeys = { "code" => "code" };
    Comm.makeOAuthRequest(requestUrl, requestParams, resultUrl, resultType, resultKeys);
  }

  // Callback from Grant attempt
  function handleAccessCodeResult(response) {
    if (response.data == null || response.data["code"] == null) {
      _delegate.handleError(response.responseCode + " ACC");
      return;
    }

    // Convert auth code to access token
    var url = $.ServerUrl + "/oauth/token";
    var params = {
        "client_id" => $.ClientId,
        "client_secret" => $.ClientSecret,
        "redirect_uri"=> $.RedirectUri,
        "grant_type" => "authorization_code",
        "code" => response.data["code"]
    };
    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_POST
    };
    Communications.makeWebRequest(url, params, options, method(:handleAccessTokenResponse));
  }

  // Handle the token response
  function handleAccessTokenResponse(responseCode, data) {
    Sys.println("handleAccessTokenResponse" + responseCode + ", " + data);

    // If we got data back then we were successful. Otherwise
    // pass the error onto the delegate
    if (data == null) {
      _delegate.handleError(responseCode + " TOK");
    } else if (data["error_description"]) {
      _delegate.handleError(data["error_description"]);
    } else {
      _delegate.handleResponse(data);
    }
  }
}


class GrantRequestDelegate extends RequestDelegate {

  // Constructor
  function initialize() {
    RequestDelegate.initialize();
  }

  // Handle a successful response from the server
  function handleResponse(data) {
    // Store access token and user_id in app properties
    App.getApp().setProperty("access_token", data["access_token"]);
    App.getApp().setProperty("user_id", data["user_id"]);
    // Switch to the data view
    Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
  }

}
