require_relative "manager"

module S3Manager
  module Resource

    def self.included(base)
      base.class_eval do
        # rebuild the object key for the new filename if the filename has
        # changed for the resource, but only if the target resources is a
        # descendant of ActiveRecord::Base
        #
        if defined?(ActiveRecord) && base.ancestors.include?(ActiveRecord::Base)

         # let's save the name of the export so we don't have to do it later.
         # also this needs to be done before we rebuild the export filename
         # as otherwise the object key rebuild won't trigger
         #
         before_save :cache_export_filename

         # let's build and save this on create even though we don't have the
         # created_at timestamp from the creation itself, this prevents us from
         # needing to save the resource twice just to get the creation timestamp
         #
         before_save :rebuild_s3_object_key, if: :export_filename_changed?

         # if we destroy the export successfully clean the data off of S3
         #
         after_destroy :delete_object_from_s3
        end
      end
    end

    def s3_manager
      @s3_manager ||= ::S3Manager::Manager.new
    end

    def upload_file_to_s3(file_path)
      s3_manager.put_encrypted_object(s3_object_key, file_path)
    end

    def fetch_object_from_s3
      s3_manager.get_encrypted_object(s3_object_key)
    end

    def write_s3_object_to_file(target_file_path)
      s3_manager.write_encrypted_object_to_file(s3_object_key, target_file_path)
    end

    def stream_s3_object_body
      s3_object = fetch_object_from_s3
      return unless s3_object && s3_object.body
      s3_object.body.read
    end

    def delete_object_from_s3
      return false unless s3_object_exists?
      s3_manager.delete_object s3_object_key
    end

    def s3_object_exists?
      return false unless s3_object_key
      s3_object_summary.exists?
    end

    def s3_object_summary
      @s3_object_summary ||= ::S3Manager::Manager::ObjectSummary
        .new(s3_object_key, s3_manager)
    end

    def presigned_s3_url
      return unless s3_object_key
      s3_manager.bucket.object(s3_object_key)
        .presigned_url(:get, expires_in: 604800).to_s
    end

    def rebuild_s3_object_key
      self[:s3_object_key] = build_s3_object_key export_filename
    end

    def build_s3_object_key(object_filename)
      key_pieces = [ s3_object_key_prefix, object_filename ]
      key_pieces.unshift ENV["AWS_S3_DEVELOPER_TAG"] if Rails.env.development?
      key_pieces.join "/"
    end

    def cache_export_filename
      self[:export_filename] = url_safe_filename
    end
  end
end
