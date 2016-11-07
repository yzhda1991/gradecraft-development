class AddRecipientIdToAnnouncements < ActiveRecord::Migration[5.0]
  def change
    add_reference :announcements, :recipient, references: :users, index: true
    add_foreign_key :announcements, :users, column: :recipient_id
  end
end
