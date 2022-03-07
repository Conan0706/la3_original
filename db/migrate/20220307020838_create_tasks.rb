class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.text :todo
      t.datetime :due_date
      t.boolean :done
    end
  end
end
