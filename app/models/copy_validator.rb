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
  #   - lookup_key: a custom key (symbol) as defined in the COPY_ASSOCIATIONS constant
  #   - associations: any additional associations that are being copied and need validating
  def validate(model, options={})
    lookup_key = options.delete(:lookup_key) || model_type_as_symbol(model.class.name)
    additional_associations = options.delete(:associations)

    associations = COPY_ASSOCIATIONS[lookup_key].try(:clone)
    associations << additional_associations unless additional_associations.blank?

    validate_model model
    validate_associations model, associations.flatten unless associations.blank?

    self
  end

  private

  # Validate a single model and append result
  def validate_model(model)
    errors = model.errors.full_messages unless model.valid?
    result = CopyValidatorResult.new(model_type_as_symbol(model.class.name), model.id, model.valid?, errors)
    append_result(model_type_as_symbol(model.class.name.pluralize), result.to_h)
  end

  # Recursively validate associated models
  def validate_models(models, type)
    if models.is_a? Enumerable  # e.g. assignments
      models.each do |am|
        validate(am, { lookup_key: type })
      end
    else  # e.g. rubric
      validate(models, { lookup_key: type })
    end
  end

  # Example: model is a course
  # For every corresponding association to be copied in the COPY_ASSOCIATIONS hash,
  # i.e. [:badges, :assignment_types, :rubrics, :challenges, :grade_scheme_elements]
  # validate all related models, whether one or many
  # course.badges, course.assignment_types, etc.
  def validate_associations(model, associations)
    associations.each do |a|
      assoc = model.send(a)
      next if assoc.nil?

      validate_models assoc, a
    end
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
    @type = type
    @id = id
    @valid = valid
    @errors = errors
  end

  def to_h
    self.instance_values.symbolize_keys
  end
end

class CopyValidationError < StandardError
  attr_reader :details

  def initialize(details, msg="One or more associations were invalid")
    @details = details
    super(msg)
  end
end
