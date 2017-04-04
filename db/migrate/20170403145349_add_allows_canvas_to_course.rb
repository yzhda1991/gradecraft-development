class AddAllowsCanvasToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :allows_canvas, :boolean, null: false, default: true
  end
end
