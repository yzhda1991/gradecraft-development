class AddGradeReadState < ActiveRecord::Migration
  def change
  	add_column :grades, :feedback_read, :boolean
  	add_column :grades, :feedback_read_date, :datetime
  end
end
