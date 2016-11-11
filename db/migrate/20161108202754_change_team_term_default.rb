class ChangeTeamTermDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :courses, :team_term, :string, default: "Section", null: false
  end
end
