class RenameCsvCheck < ActiveRecord::Migration
  def change
    rename_column :submissions_exports, :export_csv_successful, :confirm_export_csv_integrity
  end
end
