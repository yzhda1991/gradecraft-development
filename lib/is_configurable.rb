# this should be extended in the target class/module
module IsConfigurable
  attr_writer :configuration

  def configuration
    @configuration ||= const_get("Configuration").new
  end

  def reset
    @configuration = const_get("Configuration").new
  end

  def configure
    yield configuration
  end
end
