require_relative '../../lib/inheritable_ivars'
require_relative '../support/test_classes/lib/inheritable_ivars/ivar_inheritance_superclass'
require_relative '../toolkits/lib/inheritable_ivars/shared_examples'

describe InheritableIvars, type: :library do
  include Toolkits::Lib::InheritableIvarsToolkit::SharedExamples

  # InheritableIvars is extended here
  # pulled in from /spec/support/test_classes/inheritable_ivars
  let(:superclass) { IvarInheritanceSuperclass }

  it_behaves_like "some @ivars are inheritable by subclasses", IvarInheritanceSuperclass
end
