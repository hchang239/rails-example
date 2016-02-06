class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    # Defines 'multiple key index'
    # Multiple Key Index allows to search in subset
    add_index :microposts, [:user_id, :created_at]
  end
end