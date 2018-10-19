class CreateUserPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :user_preferences do |t|
      t.belongs_to :user, foreign_key: true
      t.string :search_input
      t.string :repos

      t.timestamps
    end
  end
end
