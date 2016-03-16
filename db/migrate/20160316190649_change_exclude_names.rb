class ChangeExcludeNames < ActiveRecord::Migration
  def change
    rename_column :grades, :excluded_date, :excluded_at
    rename_column :grades, :excluded_by, :excluded_by_id
  end
end
