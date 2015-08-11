class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :title
      t.text :body
      t.integer :author_id, index: true
      t.references :course, index: true

      t.timestamps null: false
    end
    add_foreign_key :announcements, :users, column: :author_id
    add_foreign_key :announcements, :courses
  end
end
