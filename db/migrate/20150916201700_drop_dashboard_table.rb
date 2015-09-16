class DropDashboardTable < ActiveRecord::Migration
  def change
    drop_table :dashboards
  end
end
