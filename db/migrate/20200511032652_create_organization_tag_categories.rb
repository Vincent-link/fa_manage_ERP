class CreateOrganizationTagCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_tag_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
