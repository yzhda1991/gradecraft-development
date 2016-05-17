class ProctorConditionsTestClass
  include Proctor::Conditions

  defer_to_proctor :test_method

  def test_conditions
    add_requirements :foo_equals_bar, :foo_equals_foo
    add_override :bar_equals_david_hasselhoff
    add_override :hasselhoff_is_awesome
  end

  def foo_equals_bar
    "foo" == "bar"
  end

  def foo_equals_foo
    "foo" == "foo"
  end

  def bar_equals_david_hasselhoff
    "bar" == "David Hasselhoff"
  end

  def hasselhoff_is_awesome
    Awesomeness.new == "David Hasselhoff"
  end

  class Awesomeness
    def ==(hasselhoff)
      hasselhoff.equal? "David Hasselhoff"
    end
  end
end
