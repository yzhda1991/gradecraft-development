module ScoreLevelable
  extend ActiveSupport::Concern

  class_methods do
    def score_levels(levels, *options)
      has_many levels, *options
      accepts_nested_attributes_for levels, allow_destroy: true,
        reject_if: proc { |a| a["value"].blank? || a["name"].blank? }
    end
  end
end
