# this should be extended in the target class
module IsConfigurable
  class << self
    attr_writer :config
  end

  def self.config
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
