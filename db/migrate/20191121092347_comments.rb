class Comments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :user
      t.references :task
      t.text :answer
      t.timestamps null: false
    end
  end
end
