require "rack/test"

module FileHelpers
  # fixture file no longer works, this is a workaround
  # here is an alternative solution that didn't work for me:
  # http://stackoverflow.com/questions/9011425/fixture-file-upload-has-file-does-not-exist-error
  def fixture_file(file, filetype="image/jpg")
    Rack::Test::UploadedFile.new(File.join("./spec", "fixtures", "files", file), filetype)
  end
end
