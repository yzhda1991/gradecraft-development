describe InheritableIvars, type: :vendor_library do
  include Toolkits::Lib::InheritableIvarsToolkit::SharedExamples

  # InheritableIvars is extended in the target class IvarInheritanceSuperclass
  # which is defined in /spec/support/test_classes/inheritable_ivars
  it_behaves_like "some @ivars are inheritable by subclasses", IvarInheritanceSuperclass
end
