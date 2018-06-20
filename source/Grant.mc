using Toybox.Communications as Comm;
using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

const RedirectUri = "https://localhost";
const Scope = "TAO_MOBILE";

// Obtain and store an Oauth2 token for API access
class GrantRequest
{
  private var _delegate;
  private var _clearAuth;

  function initialize(delegate, clearAuth) {
    _delegate = delegate;
    _clearAuth = clearAuth;
    Comm.registerForOAuthMessages(method(:handleAccessCodeResult)); // May fire immediately
    System.println("Grant(" + clearAuth + ")");
  }

  function start() {
    var requestUrl = $.ServerUrl + "/oauth/authorise";
    var requestParams = {
      "client_id" => $.ClientId,
      "response_type" => "code",
      "scope" => $.Scope,
      "redirect_uri" => $.RedirectUri,
      "logout" => _clearAuth ? "1" : "0"
    };
    var resultUrl = $.RedirectUri;
    var resultType = Comm.OAUTH_RESULT_TYPE_URL;
    var resultKeys = { "code" => "code" };
    Comm.makeOAuthRequest(requestUrl, requestParams, resultUrl, resultType, resultKeys);
  }

  // Callback from Grant attempt
  function handleAccessCodeResult(response) {
    if (response.data == null || response.data["code"] == null) {
      Error.showErrorMessage(Ui.loadResource(Rez.Strings.errorResponse) + response.responseCode);
      return;
    }

    // Convert auth code to access token
    var url = $.ServerUrl + "/oauth/token";
    var params = {
        "client_id" => $.ClientId,
        "client_secret" => $.ClientSecret,
        "redirect_uri"=> $.RedirectUri,
        "grant_type" => "authorization_code",
        "code" => response.data["code"],
        "jsonErrors" => 1
    };
    var options = {
      :method => Comm.HTTP_REQUEST_METHOD_POST
    };
    Comm.makeWebRequest(url, params, options, method(:handleAccessTokenResponse));
  }

  // Handle the token response
  function handleAccessTokenResponse(responseCode, data) {
    // jsonErrors workaround non 200 response codes being flattened out
    if (responseCode == 200 && data["responseCode"] != null) {
      responseCode = data["responseCode"];
    }
    System.print("Grant: handleAccessTokenResponse: " + responseCode + " ");
    System.println(data);

    // If we got data back then we were successful. Otherwise
    // pass the error onto the delegate

    if (responseCode == 200) {
      if (data == null) {
        Error.showErrorResource(Rez.Strings.noDataFromServer);
      } else {
        _delegate.handleResponse(data);
      }
    } else {
      _delegate.handleErrorResponseCode("grant", responseCode);
    }
  }
}

class GrantRequestDelegate extends RequestDelegate {

  private var mModel;

  // Constructor
  function initialize(clearAuth) {
    RequestDelegate.initialize();
    mModel = Application.getApp().model;
    if (clearAuth) {
      mModel.setAccessToken(null);
    }
  }

  // Handle a successful response from the server
  function handleResponse(data) {
    // Store access token
    mModel.setAccessToken(data["access_token"]);
    // Switch to the data view
    Ui.switchToView(new DownloadView(), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
  }

}
