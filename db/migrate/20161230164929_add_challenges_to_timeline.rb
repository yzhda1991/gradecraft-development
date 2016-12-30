class AddChallengesToTimeline < ActiveRecord::Migration[5.0]
  def change
    add_column :challenges, :include_in_timeline, :boolean, default: false, null: false
  end
end
