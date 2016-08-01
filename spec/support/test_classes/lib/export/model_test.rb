require "export"

class ExportModelTest
  include Export::Model
  attr_accessor :s3_object_key

  def initialize(options={})
    @s3_object_key = options[:s3_object_key]
  end
end
