class AddTagCategory < ActiveRecord::Migration[6.0]
  def change
    create_table :tag_categories do |t|
      t.string :name
    end
  end
end
