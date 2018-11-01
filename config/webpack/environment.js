const path = require("path");
const { environment } = require('@rails/webpacker')
const coffee = require('./loaders/coffee')
const webpack = require("webpack")

environment.loaders.append('coffee', coffee)

environment.plugins.prepend(
  "jquery",
  new webpack.ProvidePlugin({
    "$": "jquery",
    "_": "lodash",
    "window.jQuery": "jquery",
    "main": "main",
  })
);

module.exports = environment
