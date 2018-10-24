const path = require("path");
const { environment } = require('@rails/webpacker')
const coffee = require('./loaders/coffee')
const webpack = require("webpack")

module.exports = {
  resolve: {
    alias: {
      main: path.resolve(__dirname, "./main.coffee")
    }
  }
}

environment.loaders.append('coffee', coffee)

environment.plugins.prepend(
  "jquery",
  new webpack.ProvidePlugin({
    $: "jquery",
    _: "lodash",
    "window.jQuery": "jquery",
    "main": "main"
  })
);

module.exports = environment
