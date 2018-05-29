"use strict";

var _config = document.getElementById("rollbar-js");
var _accessToken = "POST_CLIENT_ITEM_ACCESS_TOKEN";
var _environment = "unknown";
var _person = undefined;

if (_config != null) {
  _person = JSON.parse(_config.getAttribute("data-person"));
  _accessToken = _config.getAttribute("data-client-token");
  _environment = _config.getAttribute("data-environment");
}

var _rollbarConfig = {
  accessToken: _accessToken,
  captureUncaught: true,
  captureUnhandledRejections: true,
  payload: {
    environment: _environment,
    person: _person
  }
};
