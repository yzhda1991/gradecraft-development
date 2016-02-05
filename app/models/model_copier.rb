class ModelCopier
  attr_reader :original, :copied

  def initialize(model)
    @original = model
  end

  def copy(options={})
    @copied = original.dup
    copied.copy_attributes options.delete(:attributes) {{}}
    copy_associations options.delete(:associations) {[]}
    copied
  end

  private

  def copy_associations(associations)
    ModelAssociationCopier.new(original, copied).copy([associations].flatten)
  end

  class ModelAssociationCopier
    attr_reader :original, :copied

    def initialize(original, copied)
      @original = original
      @copied = copied
    end

    def copy(associations)
      copied.save unless original.new_record?
      associations.each { |association| copy_association(association) }
    end

    def copy_association(association)
      if association.is_a? Hash
        add_association_with_attributes association
      else
        add_association association, &:copy
      end
    end

    def add_association_with_attributes(association)
      parsed = AssociationAttributeParser.new(association).parse(copied)
      add_association parsed.association do |child| child.copy(parsed.attributes) end
    end

    def add_association(association, &block)
      copied.send(association).send "<<", original.send(association).map(&block)
    end
  end

  class AssociationAttributeParser
    attr_reader :association
    attr_reader :attributes

    def initialize(association)
      @association = association
    end

    def parse(target)
      split_attributes_from_association
      @association = association.keys.first
      assign_values_to_attributes target
      self
    end

    def split_attributes_from_association
      # association is specified as { association: { attributes }} and this splits out the attributes
      @attributes = association.values.inject({}) { |hash, element| hash.merge!(element) }
    end

    def assign_values_to_attributes(target)
      attributes.each_pair do |attribute, value|
        attributes[attribute] = target.send(value) if value.is_a? Symbol
      end
    end
  end
end
