class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :image
      t.string :password_digest
      t.boolean :mentor
    end
  end
end
