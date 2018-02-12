require "active_support"

# Meant for inclusion in ActiveRecord files that are persisting CarrierWave objects via S3
module S3Manager
  module Carrierwave
    extend ActiveSupport::Concern

    # Legacy submission files were handled by S3 direct upload and we stored their
    # Amazon key in the "filepath" field. Here we check if it has a value, and if
    # so we use this to retrieve our secure url. If not, we use the path supplied by
    # the carrierwave uploader

    attr_accessor :process_file_upload, :store_dir

    included do
      before_create :cache_store_dir
    end

    include S3Manager::Basics

    def url
      return nil unless s3_object
      s3_object.presigned_url(:get, expires_in: 900).to_s
    end

    def s3_object
      bucket.object(s3_object_file_key)
    end

    def mark_missing
      update_attributes file_missing: true
    end

    def delete_from_s3
      s3_object.delete
    end

    def exists_on_s3?
      s3_object.exists?
    end

    def s3_object_file_key
      if read_attribute(:store_dir) && mounted_filename
        cached_file_path # build a full file path from cached #store_dir and #filename attributes on the FooFile record
      elsif filepath_includes_filename?
        CGI::unescape(filepath)
      else
        file.path
      end
    end

    def write_s3_object_to_disk(object_key, target_file_path)
      client.get_object({
        response_target: target_file_path,
        bucket: bucket_name,
        key: object_key
      })
    end

    def cached_file_path
      @cached_file_path ||=
        [read_attribute(:store_dir), mounted_filename].join "/"
    end

    def mounted_filename
      read_attribute(file.mounted_as)
    end

    def filepath_includes_filename?
      filepath.present? && filepath.include?(filename)
    end

    protected

    def cache_store_dir
      self[:store_dir] = file.store_dir
    end
  end
end
