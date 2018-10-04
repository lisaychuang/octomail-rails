class CreateRepos < ActiveRecord::Migration[5.2]
  def change
    create_table :repos do |t|
      t.integer :gid
      t.string :name
      t.string :full_name
      t.string :repo_url
    end
  end
end
