require "webmock/rspec"

RSpec.configure do |config|
  config.around(:each) do |example|
    WebMock.disable_net_connect!(allow_localhost: true)
    example.run
    WebMock.allow_net_connect!
  end
end
