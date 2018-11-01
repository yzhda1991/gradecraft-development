/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// import "../src/js/your_js_filename";

function requireAll(r) {
  r.keys().forEach(r);
}

import "angular";
import "ngdraggable"
import "restangular"
import "angular-animate"
import "angular-dragdrop"
import "angular-ui-router"
import "angular-resource"
import "rollbar"
import "ng-rollbar"

import "../src/js/angular/ui/sortable.js"
import "../src/js/angular/helpers/angular-froala.js"

import "../main.coffee"
requireAll(require.context("../src/js/angular/vendor", true, /\.(js$|coffee$)/));
requireAll(require.context("../src/js/angular/helpers", true, /\.(js$|coffee$)/));
requireAll(require.context("../src/js/angular/services", true, /\.(js$|coffee$)/));
// requireAll(require.context("../src/js/angular/directives", true, /\.(js$|coffee$)/));

import "../src/js/angular/directives/analytics/weekly_stats"

console.log('Hello World from Webpacker')