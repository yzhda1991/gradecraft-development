class IsConfigurableTestClass
  extend IsConfigurable

  class Configuration
    attr_accessor :waffle_name, :pancake_size
  end
end
