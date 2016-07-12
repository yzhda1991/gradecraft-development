require "webmock/rspec"

RSpec.configure do |config|
  config.around(:each, type: :disable_external_api) do |example|
    WebMock.disable_net_connect!(allow_localhost: true)
    example.run
    WebMock.allow_net_connect!
  end
end
