class AddMissingNoteBoolean < ActiveRecord::Migration
  def change
    add_column :submissions_exports, :write_note_for_missing_binary_files, :boolean, default: false
  end
end
