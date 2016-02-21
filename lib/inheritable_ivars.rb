# this module adds some logic for automatically setting instance variables from
# superclasses on their descendents. As with all such behaviors in Ruby, if those
# instance variables are overwritten on the subclass then the superclass ivar
# values will be ignored

module InheritableIvars
  # allow sub-classes to inherit class-level instance variables
  def inherited(subclass)
    inheritable_instance_variable_names.each do |ivar|
      subclass.instance_variable_set(ivar, instance_variable_get(ivar))
    end
  end

  # get a list of instance variable names for inheritance
  def inheritable_instance_variable_names
    inheritable_ivars.collect {|attr_name| "@#{attr_name}" }
  end
end
