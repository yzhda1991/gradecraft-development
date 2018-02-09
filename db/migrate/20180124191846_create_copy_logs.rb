class CreateCopyLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :copy_logs do |t|
      t.text :log
      t.integer :course_id
      t.timestamps
    end
  end
end
