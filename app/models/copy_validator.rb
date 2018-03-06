class CopyValidator
  # The definitive structure for which associations are copied and should be validated
  # Has to be manually updated for now each time an association is added to the copy
  # process
  COPY_ASSOCIATIONS ||= {
    course: [:badges, :assignment_types, :rubrics, :challenges, :grade_scheme_elements],
    assignment_types: [:assignments],
    assignments: [:assignment_score_levels],
    rubric: [:criteria],
    criteria: [:levels],
    levels: [:level_badges]
  }.freeze

  attr_accessor :details, :has_errors

  def initialize
    @details = {}
    @has_errors = false
  end

  # model: the model to validate
  # lookup_key: should match the key as specified in COPY_ASSOCIATIONS hash, e.g. criteria as opposed to criterion
  # options: hash containing either
  #   - lookup_key: a custom key as defined in the COPY_ASSOCIATIONS constant
  #   - associations: any additional associations that are being copied and need validating
  def validate(model, options={})
    lookup_key = options.delete(:lookup_key) || model_type_as_symbol(model.class.name)
    additional_associations = options.delete(:associations)

    associations = COPY_ASSOCIATIONS[lookup_key]
    associations << additional_associations unless additional_associations.blank?

    validate_model model
    validate_associations model, associations.flatten unless associations.blank?

    self
  end

  private

  def validate_model(model)
    append_result(model_type_as_symbol(model.class.name.pluralize), result_hash(model))
  end

  def validate_associations(model, associations)
    associations.each do |a|
      model.send(a).each do |am|
        validate(am, { lookup_key: a })
      end
    end
  end

  def result_hash(model)
    errors = model.errors.full_messages unless model.valid?
    CopyValidatorResult.new(model_type_as_symbol(model.class.name), model.id, model.valid?, errors).to_h
  end

  def append_result(model_name, validation)
    @has_errors = true unless validation[:valid]

    if @details[model_name].present?
      @details[model_name] << validation
    else
      @details[model_name] = [validation]
    end
  end

  def model_type_as_symbol(name)
    name.underscore.to_sym
  end
end

class CopyValidatorResult
  attr_reader :type, :id, :valid, :errors

  def initialize(type, id, valid, errors)
    @type, @id, @valid, @errors = type, id, valid, errors
  end

  def to_h
    self.instance_values.symbolize_keys
  end
end

class InvalidAssociationError < StandardError
  attr_reader :details

  def initialize(details, msg="One or more associations were invalid")
    @details = details
    super(msg)
  end
end
