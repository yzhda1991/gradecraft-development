module MultipleFileAttributes
  extend ActiveSupport::Concern

  class_methods do
    def multiple_files(files_attributes)
      define_method "#{files_attributes}_attributes=" do |attributes|
        files = attributes["0"]["file"]
        super files.map { |f| { file: f, filename: f.original_filename } }
      end
    end
  end
end
