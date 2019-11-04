class AddCompletedAndSoOnToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks,  :question, :text
    add_column :tasks, :completed, :boolean
  end
end
