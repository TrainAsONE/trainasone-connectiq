using Toybox.Communications as Comm;
using Toybox.System;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

const RedirectUri = "https://localhost";
const Scope = "WORKOUT";

const OAUTH_CODE = "code";
const OAUTH_ERROR = "error";
const OAUTH_ERROR_DESCRIPTION = "error_description";
const HTTP_STATUS_OK = 200;

// Obtain and store an Oauth2 token for API access
class GrantRequest
{
  private var mModel;
  private var _delegate;
  private var _clearAuth;

  function initialize(delegate, clearAuth) {
    mModel = Application.getApp().model;
    _delegate = delegate;
    _clearAuth = clearAuth;
    Comm.registerForOAuthMessages(method(:handleAccessCodeResult)); // May fire immediately
    // System.println("Grant(" + clearAuth + ")");
  }

  function start() {
    var requestUrl = mModel.serverUrl + "/oauth/authorise";
    var requestParams = {
      "client_id" => $.ClientId,
      "response_type" => OAUTH_CODE,
      "scope" => $.Scope,
      "redirect_uri" => $.RedirectUri,
      "logout" => _clearAuth ? "1" : "0"
    };
    var resultUrl = $.RedirectUri;
    var resultType = Comm.OAUTH_RESULT_TYPE_URL;
    // Need to explicitly enumerate the parameters we want to take from the response
    var resultKeys = { OAUTH_CODE => OAUTH_CODE, OAUTH_ERROR_DESCRIPTION => OAUTH_ERROR_DESCRIPTION };
    Comm.makeOAuthRequest(requestUrl, requestParams, resultUrl, resultType, resultKeys);
  }

  // Callback from Grant attempt
  function handleAccessCodeResult(response) {
    // System.println("handleAccessCodeResult(" + response.data + ")");

    // We cannot rely on responseCode here - as simulator gives 200 but at least 735xt real device gives 2!
    // So we just check to see if we have a valid code
    if (response.data != null) {
        var code = response.data[OAUTH_CODE];
        if (code != null) {
          // Convert auth code to access token
          var url = mModel.serverUrl + "/api/oauth/token";
          var params = {
              "client_id" => $.ClientId,
              "client_secret" => $.ClientSecret,
              "redirect_uri"=> $.RedirectUri,
              "grant_type" => "authorization_code",
              OAUTH_CODE => code,
              "jsonErrors" => 1
          };
          var options = {
              :method => Comm.HTTP_REQUEST_METHOD_POST
          };
          Comm.makeWebRequest(url, params, options, method(:handleAccessTokenResponse));
          return;
       }
    }

    var error;
    if (response.data[OAUTH_ERROR_DESCRIPTION] != null) {
      error = response.data[OAUTH_ERROR_DESCRIPTION];
    } else if (response.responseCode != HTTP_STATUS_OK) {
      error = "status " + response.responseCode;
    } else {
      error =  "no data";
    }
    Error.showErrorMessage(Ui.loadResource(Rez.Strings.serverError) + error);
  }

  // Handle the token response
  function handleAccessTokenResponse(responseCode, data) {
    // jsonErrors workaround non HTTP_STATUS_OK response codes being flattened out
    if (responseCode == HTTP_STATUS_OK && data["responseCode"] != null) {
      responseCode = data["responseCode"];
    }
    // System.print("Grant: handleAccessTokenResponse: " + responseCode + " ");
    // System.println(data);

    // If we got data back then we were successful. Otherwise
    // pass the error onto the delegate

    if (responseCode == HTTP_STATUS_OK) {
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
    Ui.switchToView(new DownloadView(null), new DownloadDelegate(), Ui.SLIDE_IMMEDIATE);
  }

}
