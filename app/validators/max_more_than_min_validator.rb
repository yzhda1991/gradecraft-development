class MaxMinValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :base,
      "Maximum group size must be greater than minimum group size." \
      if (record.max_group_size? && record.min_group_size?) &&
         (record.max_group_size < record.min_group_size)
  end
end
