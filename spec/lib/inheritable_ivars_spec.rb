require_relative '../../lib/inheritable_ivars'
require_relative '../support/test_classes/lib/inheritable_ivars/ivar_inheritance_superclass'
require_relative '../toolkits/lib/inheritable_ivars/shared_examples'

describe InheritableIvars, type: :vendor_library do
  include Toolkits::Lib::InheritableIvarsToolkit::SharedExamples

  # InheritableIvars is extended in the target class IvarInheritanceSuperclass
  # which is defined in /spec/support/test_classes/inheritable_ivars
  it_behaves_like "some @ivars are inheritable by subclasses", IvarInheritanceSuperclass
end
