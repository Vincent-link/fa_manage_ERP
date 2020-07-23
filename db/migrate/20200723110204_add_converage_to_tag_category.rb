class AddConverageToTagCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :tag_categories, :coverage, :string, array: true
  end
end
