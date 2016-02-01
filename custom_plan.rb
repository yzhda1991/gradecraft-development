# ./custom_plan.rb
require 'zeus/rails'

class CustomPlan < Zeus::Rails
  # def test
  #   Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
  #   Dir[Rails.root.join('spec/controllers/shared_specs/**/*.rb')].each { |f| puts "reloading #{f}";load f }
  #   super
  # end
end

Zeus.plan = CustomPlan.new

