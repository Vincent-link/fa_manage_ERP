class CreateSsoClientTables < ActiveRecord::Migration[5.1]
  def change
    create_table :dict_versions do |t|
      t.string :dict_version
      t.string :user_version
    end

    create_table :sso_teams do |t|
      t.string :name, null: false
      t.integer :parent_id
      t.integer :team_type
      t.integer :serial, null: false
      t.boolean :available, :default => true
      t.timestamps null: false
      t.timestamp :deleted_at, index: true
    end unless table_exists? :sso_teams

    create_table :sso_grades do |t|
      t.string :name, null: false
      t.integer :serial, null: false
      t.timestamps null: false
      t.timestamp :deleted_at, index: true
    end
  end
end
