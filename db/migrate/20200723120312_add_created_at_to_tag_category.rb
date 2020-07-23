class AddCreatedAtToTagCategory < ActiveRecord::Migration[6.0]
  def change
    drop_table :tag_categories
    create_table :tag_categories do |t|
      t.string :name

      t.timestamps
    end

    TagCategory.create(name: "机构标签")
    TagCategory.create(name: "公司标签")
    TagCategory.create(name: "投资人标签")
  end
end
