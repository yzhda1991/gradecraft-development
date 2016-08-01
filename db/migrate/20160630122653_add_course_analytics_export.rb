class AddCourseAnalyticsExport < ActiveRecord::Migration
  def change
    create_table :course_analytics_exports do |t|
      t.integer  "course_id",                             null: false
      t.integer  "professor_id",                          null: false
      t.text     "export_filename"
      t.text     "s3_object_key"
      t.text     "s3_bucket_name"
      t.text     "performer_error_log",      default: [], null: false, array: true
      t.datetime "last_export_started_at"
      t.datetime "last_export_completed_at"
      t.string   "last_completed_step"
      t.datetime "created_at",                            null: false
      t.datetime "updated_at",                            null: false
    end
  end
end
