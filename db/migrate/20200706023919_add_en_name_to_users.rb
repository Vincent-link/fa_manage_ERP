class AddEnNameToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :en_name, :string
  end
end
