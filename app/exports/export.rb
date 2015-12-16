# @mz todo: add specs
class Export < ActiveRecord::Base
  before_create :set_s3_symmetric_key

  def initialize(filename
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new
  end

  def s3_bucket
    @s3_bucket ||= s3_client.buckets["gradecraft-#{Rails.env}"]
  end

  def s3_object_key_path
    "/exports"
  end

  def set_s3_symmetric_key
    self[:s3_symmetric_key] = OpenSSL::Cipher.new("AES-256-ECB").random_key
  end
end
