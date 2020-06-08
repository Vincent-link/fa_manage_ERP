class AddNameToTagCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :tag_categories, :name, :string
  end
end
