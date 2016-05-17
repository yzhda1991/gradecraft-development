class ProctorConditionsTestClass
  include Proctor::Conditions

  defer_to_proctor :test_method
end
