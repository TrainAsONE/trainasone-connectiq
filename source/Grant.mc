import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const RedirectUri = "https://localhost";
const Scope = "WORKOUT";

const OAUTH_CODE = "code";
const OAUTH_ERROR = "error";
const OAUTH_ERROR_DESCRIPTION = "error_description";
const HTTP_STATUS_OK = 200;

// Obtain and store an Oauth2 token for API access
class GrantRequest {
  private var mModel as TaoModel;
  private var _delegate as GrantRequestDelegate;
  private var _clearAuth as Boolean;

  function initialize(delegate as GrantRequestDelegate, clearAuth as Boolean) {
    mModel = Application.getApp().model;
    _delegate = delegate;
    _clearAuth = clearAuth;
    Communications.registerForOAuthMessages(method(:handleAccessCodeResult)); // May fire immediately
    // Application.getApp().log("Grant(" + clearAuth + ")");
  }

  function start() as Void {
    var requestUrl = mModel.serverUrl + "/oauth/authorise";
    var requestParams =
      {
        "client_id" => $.ClientId,
        "response_type" => OAUTH_CODE,
        "scope" => $.Scope,
        "redirect_uri" => $.RedirectUri,
        "logout" => _clearAuth ? "1" : "0",
      } as Dictionary<String, String>;
    var resultUrl = $.RedirectUri;
    var resultType = Communications.OAUTH_RESULT_TYPE_URL;
    // Need to explicitly enumerate the parameters we want to take from the response
    var resultKeys =
      {
        OAUTH_CODE => OAUTH_CODE,
        OAUTH_ERROR_DESCRIPTION => OAUTH_ERROR_DESCRIPTION,
      } as Dictionary<String, String>;
    Communications.makeOAuthRequest(
      requestUrl,
      requestParams,
      resultUrl,
      resultType,
      resultKeys
    );
  }

  // Callback from Grant attempt
  function handleAccessCodeResult(response as OAuthMessage) as Void {
    // Application.getApp().log("handleAccessCodeResult(" + response.data + ")");

    // We cannot rely on responseCode here - as simulator gives 200 but at least 735xt real device gives 2!
    // So we just check to see if we have a valid code
    if (response.data != null) {
      var code = response.data[OAUTH_CODE];
      if (code != null) {
        // Convert auth code to access token
        var url = mModel.serverUrl + "/api/oauth/token";
        var params =
          {
            "client_id" => $.ClientId,
            "client_secret" => $.ClientSecret,
            "redirect_uri" => $.RedirectUri,
            "grant_type" => "authorization_code",
            OAUTH_CODE => code,
            "jsonErrors" => "true",
          } as Dictionary<String, String>;
        var options = {
          :method => Communications.HTTP_REQUEST_METHOD_POST,
        };
        Communications.makeWebRequest(
          url,
          params,
          options,
          method(:handleAccessTokenResponse)
        );
        return;
      }
    }

    var error;
    if (
      response.data != null &&
      response.data[OAUTH_ERROR_DESCRIPTION] != null
    ) {
      error = response.data[OAUTH_ERROR_DESCRIPTION];
    } else if (response.responseCode != HTTP_STATUS_OK) {
      error = "status " + response.responseCode;
    } else {
      error = "no data";
    }
    (new MessageUtil()).showErrorMessage(
      (WatchUi.loadResource(Rez.Strings.serverError) as String) + error
    );
  }

  // Handle the token response
  function handleAccessTokenResponse(
    responseCode as Number,
    data as Null or Dictionary or String
  ) as Void {
    responseCode = NetUtil.extractResponseCode(responseCode, data);
    // If we got data back then we were successful. Otherwise
    // pass the error onto the delegate

    if (responseCode == HTTP_STATUS_OK) {
      if (data == null) {
        (new MessageUtil()).showErrorResource(Rez.Strings.noDataFromServer);
      } else {
        _delegate.handleResponse(data);
      }
    } else {
      _delegate.handleErrorResponseCode("grant", responseCode);
    }
  }
}

class GrantRequestDelegate extends RequestDelegate {
  private var mModel as TaoModel;

  // Constructor
  function initialize(clearAuth as Boolean) {
    RequestDelegate.initialize();
    mModel = Application.getApp().model;
    if (clearAuth) {
      mModel.setAccessToken(null);
    }
  }

  // Handle a successful response from the server
  function handleResponse(data as Dictionary<String, String>) as Void {
    // Store access token
    mModel.setAccessToken(data["access_token"]);
    // Switch to the data view
    WatchUi.switchToView(
      new DownloadView(null),
      new DownloadDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
