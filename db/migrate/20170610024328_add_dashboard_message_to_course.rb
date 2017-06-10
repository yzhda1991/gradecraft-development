class AddDashboardMessageToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :dashboard_message, :text
  end
end
