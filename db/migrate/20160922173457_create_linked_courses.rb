class CreateLinkedCourses < ActiveRecord::Migration
  def change
    create_table :linked_courses do |t|
      t.references :course, index: true, foreign_key: true
      t.string :provider
      t.string :provider_resource_id
      t.datetime :last_linked_at

      t.timestamps null: false
    end
  end
end
