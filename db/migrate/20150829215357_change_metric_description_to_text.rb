class ChangeMetricDescriptionToText < ActiveRecord::Migration
  def change
    change_column :metrics, :description, :text
  end
end
