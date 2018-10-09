const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')
const webpack = require("webpack")

environment.loaders.append('coffee', coffee)

environment.plugins.prepend(
  "jquery",
  new webpack.ProvidePlugin({
    $: "jquery",
    "window.jQuery": "jquery"
  })
);

module.exports = environment
