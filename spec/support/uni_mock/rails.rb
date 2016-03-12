module UniMock
  module StubRails
    def stub_env(env_name)
      allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new(env_name) }
    end
  end
end
