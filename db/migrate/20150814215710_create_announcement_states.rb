class CreateAnnouncementStates < ActiveRecord::Migration
  def change
    create_table :announcement_states do |t|
      t.references :announcement, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.boolean :read, default: true

      t.timestamps null: false
    end
  end
end
