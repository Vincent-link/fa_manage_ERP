class CreateTagCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :tag_categories do |t|

      t.timestamps
    end
  end
end
