class CreateChats < ActiveRecord::Migration[6.1]
  def change
    create_table :chats do |t|
      t.integer :user_id
      t.integer :group_id
      t.text :comment
      t.string :image
    end
  end
end
