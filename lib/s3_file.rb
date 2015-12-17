module S3File

  # Legacy submission files were handled by S3 direct upload and we stored their
  # Amazon key in the "filepath" field. Here we check if it has a value, and if
  # so we use this to retrieve our secure url. If not, we use the path supplied by
  # the carrierwave uploader

  attr_accessor :process_file_upload

  def build_s3_client
    @s3_client ||= Aws::S3::Client.new
  end

  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new
  end

  def s3_bucket
    build_s3_client
    @s3_bucket ||= s3_resource.bucket(s3_bucket_name)
  end

  def s3_bucket_name
    "gradecraft-#{Rails.env}"
  end

  def url
    return file.url if Rails.env == "development"

    if filepath.present?
      s3_bucket.object(CGI::unescape(filepath)).presigned_url(:get, expires_in: 900).to_s #15 minutes
    else
      s3_bucket.object(file.path).presigned_url(:get, expires_in: 900).to_s #15 minutes
    end
  end

  def remove
    if filepath.present?
      s3_bucket.object(CGI::unescape(filepath)).delete
    else
      s3_bucket.object(file.path).delete
    end
  end

  private

  def strip_path
    if filepath.present?
      filepath.slice! "/#{s3_bucket_name}/"
      write_attribute(:filepath, filepath)
      name = filepath.clone

      # 2015-01-06-11-16-33%2Fsome-file.jpg -> some-file.jpg
      # see s3 file structure created in /app/helpers/uploads_helper.rb
      name.slice!(/.*\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}%2F/)
      write_attribute(:filename, name)
    end
  end
end
