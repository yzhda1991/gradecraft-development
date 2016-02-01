class ChangeS3BucketToBucketName < ActiveRecord::Migration
  def change
    rename_column :assignment_exports, :s3_bucket, :s3_bucket_name
  end
end
