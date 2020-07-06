class AddColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :grade_desc, :string
    add_column :users, :tel, :string
  end
end
